open! Base
module Sdl = Tsdl.Sdl

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)

type t = { renderer : Sdl.renderer }

let init ~w ~h ~title =
  let () = ok_exn (Sdl.init Sdl.Init.(video + events)) in
  let w = ok_exn (Sdl.create_window ~w ~h title Sdl.Window.opengl) in
  let renderer = ok_exn (Sdl.create_renderer w) in
  { renderer }

module Image = struct
  type t = Sdl.texture

  let of_bmp_file display file =
    let surface = ok_exn (Sdl.load_bmp file) in
    ok_exn (Sdl.create_texture_from_surface display.renderer surface)

  let destory t = Sdl.destroy_texture t
end
