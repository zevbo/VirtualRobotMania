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
      for i = 0 to 10_000 do
        let theta = Float.of_int i *. 1.0 in
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

(* {[ exception Exit

   let () = Graphics.open_graph ""; Graphics.set_window_title "Testing, 1,2,3";
   Graphics.auto_synchronize false; try for i = 0 to 1000 do
   Graphics.clear_graph (); if Graphics.key_pressed () then raise Exit;
   Unix.sleepf 0.01; let offset = Float.of_int i /. 0.1 |> Float.to_int in
   printf "offset: %d\n%!" offset; Graphics.fill_poly [| 0 + offset, 0 + offset;
   100, 400; 400, 100 |]; Graphics.synchronize () done with | Exit -> () ]} *)
