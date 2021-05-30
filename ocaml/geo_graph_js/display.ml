open! Core_kernel
open! Async_kernel
open Geo
open Brr
module Color = Geo_graph.Color
module Canvas = Brr_canvas.Canvas
module C2d = Brr_canvas.C2d
module Matrix4 = Brr_canvas.Matrix4

(* let def fut = Deferred.create (fun ivar -> Fut.await fut (fun x -> Ivar.fill
   ivar x)) *)

let load_image url =
  let img = El.img ~at:[ At.src (Jstr.of_string url) ] () in
  let loaded = Ivar.create () in
  let on_load _ = Ivar.fill loaded () in
  let%bind () =
    Ev.listen Ev.load on_load (El.as_target img);
    Ivar.read loaded
  in
  Ev.unlisten Ev.load on_load (El.as_target img);
  return img

type t =
  { physical : int * int
  ; logical : int * int
  ; title : string
  ; log_s : Sexp.t -> unit
  ; c2d : C2d.t
  }

let init ~physical ~logical ~title ~log_s =
  let canvas = Canvas.create ~w:(fst physical) ~h:(snd physical) [] in
  Document.set_title G.document (Jstr.of_string title);
  El.set_children (Document.body G.document) [ Canvas.to_el canvas ];
  let c2d = C2d.create canvas in
  Async_js.init ();
  { physical; logical; title; log_s; c2d }

module Image = struct
  type t =
    | Image of El.t
    | Pixel of Color.t

  let pixel _display (color : Color.t) = Pixel color

  (** Javascript is garbage collected, so, no need to explicitly deallocate
      images. *)
  let destroy _t = ()

  let size t =
    match t with
    | Pixel _ -> 1, 1
    | Image image ->
      let get prop = El.prop prop image in
      get El.Prop.width, get El.Prop.height

  let of_bmp_file _ filename =
    raise_s
      [%message
        "Display.of_bmp_file is unimplemented in JavaScript" (filename : string)]

  let of_file _ ~filename =
    raise_s
      [%message
        "Display.of_file is unimplemented in JavaScript" (filename : string)]

  let of_contents _ ~contents ~format =
    raise_s
      [%message
        "Display.of_contents is unimplemented in JavaScript"
          (contents : string)
          (format : string)]

  let of_name _display name =
    let%map image = load_image name in
    Image image
end

(** Display is automatically refreshed after control is returned to browser *)
let present _t = ()

let clear t color =
  let color = C2d.color (Jstr.of_string (Color.to_js_string color)) in
  C2d.set_fill_style t.c2d color;
  let w, h = t.physical in
  C2d.fill_rect t.c2d ~x:0. ~y:0. ~w:(Float.of_int w) ~h:(Float.of_int h)

let color_to_style color =
  Color.to_js_string color |> Jstr.of_string |> C2d.color

let draw_image_base
    t
    ~(w : float)
    ~(h : float)
    ~alpha
    (image : Image.t)
    ~(center : Vec.t)
    ~angle
  =
  let iw, ih = Image.size image in
  let pw, ph = t.physical in
  C2d.scale t.c2d ~sy:(-1.) ~sx:1.;
  C2d.translate t.c2d ~x:(Float.of_int pw /. 2.) ~y:(-.Float.of_int ph /. 2.);
  C2d.translate t.c2d ~x:center.x ~y:center.y;
  C2d.rotate t.c2d (-.angle);
  C2d.scale t.c2d ~sx:(w /. Float.of_int iw) ~sy:(h /. Float.of_int ih);
  let shift x = -.Float.of_int x /. 2. in
  (match image with
  | Pixel color ->
    let color = Color.alpha color alpha |> color_to_style in
    C2d.set_fill_style t.c2d color;
    C2d.fill_rect
      t.c2d
      ~x:(shift iw)
      ~y:(shift ih)
      ~w:(Float.of_int iw)
      ~h:(Float.of_int ih)
  | Image image ->
    let src = C2d.image_src_of_el image in
    let alpha = Float.of_int alpha /. 255. in
    C2d.set_global_alpha t.c2d alpha;
    C2d.draw_image t.c2d src ~x:(shift iw) ~y:(shift ih);
    C2d.set_global_alpha t.c2d 1.);
  C2d.reset_transform t.c2d

let draw_image_wh t ~w ~h ?(alpha = 255) image ~center ~angle =
  draw_image_base t ~w ~h ~alpha image ~center ~angle

let draw_image t ?(scale = 1.0) ?alpha (img : Image.t) ~center ~angle =
  let open Float.O in
  let w, h =
    let w, h = Image.size img in
    let adj x = Float.of_int x * scale in
    adj w, adj h
  in
  draw_image_wh t ?alpha ~w ~h img ~center ~angle

let draw_line t ~width (v1 : Vec.t) (v2 : Vec.t) color =
  let path = C2d.Path.create () in
  C2d.Path.move_to path ~x:v1.x ~y:v1.y;
  C2d.Path.line_to path ~x:v2.x ~y:v2.y;
  C2d.set_line_width t.c2d width;
  C2d.set_stroke_style t.c2d (color_to_style color);
  C2d.stroke t.c2d path

(** Nothing to do in Javascript land... *)
let shutdown _t = ()

(** Again, nothing to do in Javascript land *)
let maybe_exit _t = ()

(* Can't do anything here without returning a Deferred....so, we need to fix the
   API, maybe? *)
let delay_ms _ms = ()
