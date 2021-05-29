open! Core_kernel
module Sdl = Tsdl.Sdl
open Geo
module Color = Geo_graph.Color

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)

module Image0 = struct
  type t =
    { texture : Sdl.texture
    ; size : int * int
    }
end

type t =
  { renderer : Sdl.renderer
  ; window : Sdl.window
  ; size : int * int
  ; pixel : Sdl.texture
        (** A one-pixel texture, for drawing simple rectangles *)
  ; pixel_ba : (Sdl.uint32, Bigarray.int32_elt) Sdl.bigarray
        (** The bigarray used to blit a color into our one-pixel texture. *)
  ; pixel_format : Sdl.pixel_format
  ; event : Sdl.event
  }

let set_pixel_color t color =
  let color =
    let r, g, b = Color.to_tuple color in
    Sdl.map_rgba t.pixel_format r g b 255
  in
  t.pixel_ba.{0} <- color;
  Sdl.update_texture t.pixel None t.pixel_ba 1 |> ok_exn

let init ~physical ~logical ~title =
  let () = ok_exn @@ Sdl.init Sdl.Init.(video + events) in
  let window =
    let w, h = physical in
    ok_exn @@ Sdl.create_window ~w ~h title Sdl.Window.(opengl + resizable)
  in
  let renderer = ok_exn @@ Sdl.create_renderer window in
  (let w, h = logical in
   ok_exn @@ Sdl.render_set_logical_size renderer w h);
  let pixel =
    ok_exn
    @@ Sdl.create_texture
         ~w:1
         ~h:1
         renderer
         Sdl.Pixel.format_rgba8888
         Sdl.Texture.access_streaming
  in
  { renderer
  ; window
  ; size = logical
  ; pixel
  ; pixel_ba = Bigarray.Array1.create Bigarray.Int32 Bigarray.c_layout 1
  ; pixel_format = Sdl.alloc_format Sdl.Pixel.format_rgba8888 |> ok_exn
  ; event = Sdl.Event.create ()
  }

module Image = struct
  type display = t

  include Image0

  let pixel display color =
    let color =
      let r, g, b = Color.to_tuple color in
      Sdl.map_rgba display.pixel_format r g b 255
    in
    display.pixel_ba.{0} <- color;
    let texture =
      ok_exn
      @@ Sdl.create_texture
           ~w:1
           ~h:1
           display.renderer
           Sdl.Pixel.format_rgba8888
           Sdl.Texture.access_streaming
    in
    ok_exn (Sdl.update_texture texture None display.pixel_ba 1);
    { texture; size = 1, 1 }

  let of_bmp_file (display : display) file =
    let surface = ok_exn (Sdl.load_bmp file) in
    let size = Sdl.get_surface_size surface in
    let texture =
      ok_exn (Sdl.create_texture_from_surface display.renderer surface)
    in
    { texture; size }

  let destroy t = Sdl.destroy_texture t.texture
  let size t = t.size

  let of_file display ~filename =
    let open Async in
    let bmpfile = Caml.Filename.temp_file "image" ".bmp" in
    let%bind () =
      Process.run_expect_no_output_exn
        ~prog:"/usr/local/bin/convert"
        ~args:[ filename; bmpfile ]
        ()
    in
    let image = of_bmp_file display bmpfile in
    let%bind () = Unix.unlink bmpfile in
    return image

  let of_contents t ~contents ~format =
    let open Async in
    let filename = Caml.Filename.temp_file "input-image" ("." ^ format) in
    let%bind () = Writer.save filename ~contents in
    let%bind image = of_file t ~filename in
    let%bind () = Unix.unlink filename in
    return image
end

let clear t color =
  let r, g, b = Color.to_tuple color in
  ok_exn @@ Sdl.set_render_draw_color t.renderer r g b 0;
  ok_exn @@ Sdl.render_fill_rect t.renderer None

let present t = Sdl.render_present t.renderer

(* Move from math-style coordinates (origin at zero, y goes up, x goes to the
   right) to SDL coordinates (origin at upper left, y goes down, x goes to the
   right. *)
let math_to_sdl t (v : Vec.t) =
  let open Float.O in
  let w, h = t.size in
  let f = Float.of_int in
  { Vec.x = (f w / 2.) + v.x; y = (f h / 2.) - v.y }

let _sdl_to_math t { Vec.x; y } =
  let open Float.O in
  let w, h = t.size in
  let x = -.(Float.of_int w / 2.) + x in
  let y = -.(Float.of_int h / 2.) - y in
  Vec.create x y

let radians_to_degrees x = x *. 180. /. Float.pi
let _degrees_to_radians x = x *. Float.pi /. 180.

let draw_image_wh
    t
    ~w
    ~h
    ?(alpha = 255)
    (img : Image.t)
    ~(center : Vec.t)
    ~angle:theta
  =
  let open Float.O in
  let dst =
    let corner =
      (* Why is it + h/2 for y? *)
      math_to_sdl t (Vec.create (center.x - (w / 2.)) (center.y + (h / 2.)))
    in
    let { Vec.x; y } = corner in
    let round = Float.iround_nearest_exn in
    Sdl.Rect.create ~x:(round x) ~y:(round y) ~w:(round w) ~h:(round h)
  in
  ok_exn @@ Sdl.set_texture_alpha_mod img.texture alpha;
  Sdl.render_copy_ex
    ~dst
    t.renderer
    img.texture
    (-.radians_to_degrees theta)
    None
    Sdl.Flip.none
  |> ok_exn

let draw_image t ?(scale = 1.0) ?alpha (img : Image.t) ~center ~angle =
  let open Float.O in
  let w, h =
    let w, h = img.size in
    let adj x = Float.of_int x * scale in
    adj w, adj h
  in
  draw_image_wh t ?alpha ~w ~h img ~center ~angle

let draw_line t ~width v1 v2 color =
  let round = Float.iround_nearest_exn in
  let diff = Vec.sub v2 v1 in
  let theta = Vec.angle_of diff in
  let mag = Vec.mag diff in
  let center = Vec.scale (Vec.add v1 v2) 0.5 in
  let dst =
    let open Float.O in
    let { Vec.x; y } =
      let { Vec.x; y } = center in
      math_to_sdl t (Vec.create (x - (mag / 2.)) (y + (width / 2.)))
    in
    let w = mag in
    let h = width in
    Sdl.Rect.create ~x:(round x) ~y:(round y) ~w:(round w) ~h:(round h)
  in
  set_pixel_color t color;
  Sdl.render_copy_ex
    ~dst
    t.renderer
    t.pixel
    (-.radians_to_degrees theta)
    None
    Sdl.Flip.none
  |> ok_exn

let shutdown t =
  Sdl.destroy_window t.window;
  Sdl.destroy_renderer t.renderer;
  Sdl.quit ()

(* Check for events, maybe exit if you see someone press q *)
let maybe_exit t =
  if Sdl.poll_event (Some t.event)
  then (
    match Sdl.Event.enum (Sdl.Event.get t.event Sdl.Event.typ) with
    | `Key_up ->
      let key = Sdl.Event.get t.event Sdl.Event.keyboard_keycode in
      if key = Sdl.K.q then Caml.exit 0
    | _ -> ())

let delay_ms ms = Sdl.delay (Int32.of_int_exn ms)
