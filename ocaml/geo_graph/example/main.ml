open! Base
open! Stdio
open Tsdl

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)

let main () =
  match Sdl.init Sdl.Init.video with
  | Error (`Msg e) ->
    Sdl.log "Init error: %s" e;
    Caml.exit 1
  | Ok () ->
    (match Sdl.create_window ~w:640 ~h:480 "SDL OpenGL" Sdl.Window.opengl with
    | Error (`Msg e) ->
      Sdl.log "Create window error: %s" e;
      Caml.exit 1
    | Ok w ->
      let image_surface = ok_exn (Sdl.load_bmp "SignalsandThreads-3000.bmp") in
      let renderer = ok_exn (Sdl.create_renderer w) in
      let texture =
        ok_exn (Sdl.create_texture_from_surface renderer image_surface)
      in
      let event = Sdl.Event.create () in
      for i = 0 to 10_000 do
        if (Sdl.poll_event (Some event)) then (
          match Sdl.Event.enum (Sdl.Event.get event Sdl.Event.typ) with
          | `Key_up ->
            let key = Sdl.Event.get event Sdl.Event.keyboard_keycode in
            printf "Key: %s\n%!" (Sdl.get_key_name key);
            if key = Sdl.K.q then Caml.exit 0
          | _ -> ()
        );
        let theta = Float.of_int i *. 1.0 in
        ok_exn (Sdl.set_render_draw_color renderer 255 255 100 0);
        ok_exn (Sdl.render_fill_rect renderer None);
        ok_exn
          (Sdl.render_copy_ex
             ~dst:(Sdl.Rect.create ~x:150 ~y:150 ~w:200 ~h:200)
             renderer
             texture
             theta
             None
             Sdl.Flip.none);
        Sdl.render_present renderer;
        Sdl.delay 5l
      done;
      Sdl.destroy_window w;
      Sdl.quit ();
      Caml.exit 0)

let () = main ()
