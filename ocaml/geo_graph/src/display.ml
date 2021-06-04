open! Core_kernel
open! Async_kernel
open Geo
open Brr
module Canvas = Brr_canvas.Canvas
module C2d = Brr_canvas.C2d
module Matrix4 = Brr_canvas.Matrix4

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
  { mutable physical : Vec.t
  ; x_over_y : float
  ; logical : Vec.t
  ; log_s : Sexp.t -> unit
  ; c2d : C2d.t
  }

let window_inner_w (w : Window.t) =
  let w = Window.to_jv w in
  Jv.Float.get w "innerWidth"

let window_inner_h (w : Window.t) =
  let w = Window.to_jv w in
  Jv.Float.get w "innerHeight"

let init ~physical ~logical ~title ~log_s =
  let vec (x, y) = Vec.create (Float.of_int x) (Float.of_int y) in
  let physical = vec physical in
  let logical = vec logical in
  let canvas = Canvas.create [] in
  Document.set_title G.document (Jstr.of_string title);
  let body = Document.body G.document in
  El.set_children body [ Canvas.to_el canvas ];
  let c2d = C2d.create canvas in
  Async_js.init ();
  let x_over_y = physical.x /. physical.y in
  let t = { physical; logical; log_s; c2d; x_over_y } in
  let size_canvas () =
    let win =
      Vec.create
        (window_inner_w G.window -. 10.)
        (window_inner_h G.window -. 10.)
    in
    let win_x_over_y = win.x /. win.y in
    let new_physical =
      match Float.O.(win_x_over_y > t.x_over_y) with
      | true -> Vec.create (win.y *. t.x_over_y) win.y
      | false -> Vec.create win.x (win.x /. t.x_over_y)
    in
    Canvas.set_w canvas (Float.to_int new_physical.x);
    Canvas.set_h canvas (Float.to_int new_physical.y);
    t.physical <- new_physical
  in
  size_canvas ();
  Ev.listen Ev.resize (fun _ -> size_canvas ()) (Window.as_target G.window);
  t

module Image = struct
  type t =
    | Image of El.t
    | Pixel of Color.t

  let pixel _display (color : Color.t) = Pixel color

  let size t =
    match t with
    | Pixel _ -> 1, 1
    | Image image ->
      let get prop = El.prop prop image in
      get El.Prop.width, get El.Prop.height

  let of_name _display name =
    let%map image = load_image name in
    Image image
end

let clear t color =
  let color = C2d.color (Jstr.of_string (Color.to_js_string color)) in
  C2d.set_fill_style t.c2d color;
  C2d.fill_rect t.c2d ~x:0. ~y:0. ~w:t.physical.x ~h:t.physical.y

let color_to_style color =
  Color.to_js_string color |> Jstr.of_string |> C2d.color

(* Converts the physical to the logical dimensions. Here we assume that the
   physical and logical dimensions have the same aspect ratio. The desired frame
   of reference has the origin at zero, and has positive x pointing up, and
   positive y pointing to the right, which requires a mirror tranformation *)
let physical_to_logical t =
  (* Make y point up instead of down *)
  C2d.scale t.c2d ~sy:(-1.) ~sx:1.;
  (* Move the origin to the center *)
  C2d.translate t.c2d ~x:(t.physical.x /. 2.) ~y:(-.t.physical.y /. 2.);
  (* Scale from physical to logical size dimensions *)
  let pl_ratio = t.physical.x /. t.logical.x in
  C2d.scale t.c2d ~sx:pl_ratio ~sy:pl_ratio

let draw_image_base
    t
    ~(w : float)
    ~(h : float)
    ~alpha
    (image : Image.t)
    ~(center : Vec.t)
    ~angle
  =
  (* physical-to-logical *)
  physical_to_logical t;
  (* Now, for image placement *)
  let iw, ih = Image.size image in
  C2d.translate t.c2d ~x:center.x ~y:center.y;
  C2d.rotate t.c2d angle;
  (* Undo the mirror transformation so the image isn't reversed *)
  C2d.scale t.c2d ~sy:(-1.) ~sx:1.;
  (* scale to get the image to the right size *)
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
  physical_to_logical t;
  let path = C2d.Path.create () in
  C2d.Path.move_to path ~x:v1.x ~y:v1.y;
  C2d.Path.line_to path ~x:v2.x ~y:v2.y;
  C2d.set_line_width t.c2d width;
  C2d.set_line_cap t.c2d (Jstr.of_string "round");
  C2d.set_stroke_style t.c2d (color_to_style color);
  C2d.stroke t.c2d path;
  C2d.reset_transform t.c2d
