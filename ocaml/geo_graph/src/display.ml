open! Base
module Sdl = Tsdl.Sdl
open Geo

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)

type t =
  { renderer : Sdl.renderer
  ; window : Sdl.window
  }

let init ~w ~h ~title =
  let () = ok_exn @@ Sdl.init Sdl.Init.(video + events) in
  let window = ok_exn @@ Sdl.create_window ~w ~h title Sdl.Window.opengl in
  let renderer = ok_exn @@ Sdl.create_renderer window in
  { renderer; window }

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

let draw_image t ?(scale = 1.0) (img : Image.t) v theta =
  let w, h =
    let w, h = img.size in
    let adj x = Float.iround_nearest_exn (Float.of_int x *. scale) in
    adj w, adj h
  in
  Sdl.render_copy_ex
    ~dst:
      (Sdl.Rect.create
         ~x:(Float.iround_nearest_exn (Vec.x v))
         ~y:(Float.iround_nearest_exn (Vec.y v))
         ~w
         ~h)
    t.renderer
    img.texture
    (Angle.to_degrees theta)
    None
    Sdl.Flip.none
  |> ok_exn

let shutdown t =
  Sdl.destroy_window t.window;
  Sdl.destroy_renderer t.renderer;
  Sdl.quit ()
