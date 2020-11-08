open Core_kernel
module Sdl = Tsdl.Sdl
open Geo

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)

type t =
  { renderer : Sdl.renderer
  ; window : Sdl.window
  ; size : int * int
  ; pixel : Sdl.texture
        (** A one-pixel texture, for drawing simple rectangles *)
  ; pixel_ba : (Sdl.uint32, Bigarray.int32_elt) Sdl.bigarray
        (** The bigarray used to blit a color into our one-pixel texture. *)
  ; pixel_format : Sdl.pixel_format
  }

let set_pixel_color t color =
  let color =
    let r, g, b = Color.to_tuple color in
    Sdl.map_rgba t.pixel_format r g b 255
  in
  t.pixel_ba.{0} <- color;
  Sdl.update_texture t.pixel None t.pixel_ba 1 |> ok_exn

let init ~w ~h ~title =
  let () = ok_exn @@ Sdl.init Sdl.Init.(video + events) in
  let window = ok_exn @@ Sdl.create_window ~w ~h title Sdl.Window.opengl in
  let renderer = ok_exn @@ Sdl.create_renderer window in
  let pixel =
    ok_exn
    @@ Sdl.create_texture
         ~w:1
         ~h:1
         renderer
         Sdl.Pixel.format_rgba8888
         Sdl.Texture.access_streaming
  in
  let pixel_ba = Bigarray.Array1.create Bigarray.Int32 Bigarray.c_layout 1 in
  let pixel_format = Sdl.alloc_format Sdl.Pixel.format_rgba8888 |> ok_exn in
  { renderer; window; size = w, h; pixel; pixel_ba; pixel_format }

module Image = struct
  type t =
    { texture : Sdl.texture
    ; size : int * int
    }

  let of_bmp_file display file =
    let surface = ok_exn (Sdl.load_bmp file) in
    let size = Sdl.get_surface_size surface in
    let texture =
      ok_exn (Sdl.create_texture_from_surface display.renderer surface)
    in
    { texture; size }

  let destroy t = Sdl.destroy_texture t.texture
  let size t = t.size
end

let clear t color =
  let r, g, b = Color.to_tuple color in
  ok_exn @@ Sdl.set_render_draw_color t.renderer r g b 0;
  ok_exn @@ Sdl.render_fill_rect t.renderer None

let present t = Sdl.render_present t.renderer

let math_to_sdl t { Vec.x; y } =
  let open Float.O in
  let w, h = t.size in
  let x = (Float.of_int w / 2.) + x in
  let y = (Float.of_int h / 2.) - y in
  Vec.create x y

let sdl_to_math t { Vec.x; y } =
  let open Float.O in
  let w, h = t.size in
  let x = -.(Float.of_int w / 2.) + x in
  let y = -.(Float.of_int h / 2.) - y in
  Vec.create x y

let () =
  ignore sdl_to_math;
  ignore math_to_sdl

let draw_image t ?(scale = 1.0) (img : Image.t) vec theta =
  let dst =
    let open Float.O in
    let w, h =
      let w, h = img.size in
      let adj x = Float.of_int x * scale in
      adj w, adj h
    in
    let float = Float.of_int in
    let corner =
      let { Vec.x; y } = vec in
      Vec.create
        ((float (fst t.size) / 2.) + x - (w / 2.))
        ((float (snd t.size) / 2.) - y - (h / 2.))
    in
    let { Vec.x; y } = corner in
    let round = Float.iround_nearest_exn in
    Sdl.Rect.create ~x:(round x) ~y:(round y) ~w:(round w) ~h:(round h)
  in
  Sdl.render_copy_ex
    ~dst
    t.renderer
    img.texture
    (-.Angle.to_degrees theta)
    None
    Sdl.Flip.none
  |> ok_exn

let draw_line t ~width v1 v2 color =
  set_pixel_color t color;
  let diff = Vec.sub v2 v1 in
  let theta = Vec.angle_of diff in
  let mag = Vec.mag diff in
  let center = Vec.scale (Vec.add v1 v2) 0.5 in
  let dst =
    let open Float.O in
    let { Vec.x; y } =
      let { Vec.x; y } = center in
      math_to_sdl t (Vec.create (x - (mag / 2.)) (y - (width / 2.)))
    in
    let w = width in
    let h = mag in
    print_s
      [%message
        "rect"
          (v1 : Vec.t)
          (v2 : Vec.t)
          (center : Vec.t)
          (theta : Angle.t)
          (mag : float)
          (x : float)
          (y : float)
          (w : float)
          (h : float)];
    let round = Float.iround_nearest_exn in
    Sdl.Rect.create ~x:(round x) ~y:(round y) ~w:(round w) ~h:(round h)
  in
  Sdl.render_copy_ex
    ~dst
    t.renderer
    t.pixel
    (Angle.to_degrees theta)
    None
    Sdl.Flip.none
  |> ok_exn

let shutdown t =
  Sdl.destroy_window t.window;
  Sdl.destroy_renderer t.renderer;
  Sdl.quit ()
