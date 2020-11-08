open! Base
open! Stdio
open Geo
open Geo_graph
open Tsdl

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)

let main () =
  let display = Display.init ~w:640 ~h:480 ~title:"Image Display" in
  let image = Display.Image.of_bmp_file display "SignalsandThreads-3000.bmp" in
  let event = Sdl.Event.create () in
  let i = ref 0 in
  while true do
    Int.incr i;
    let theta = Angle.of_degrees (Float.of_int !i *. 1.0) in
    if Sdl.poll_event (Some event)
    then (
      match Sdl.Event.enum (Sdl.Event.get event Sdl.Event.typ) with
      | `Key_up ->
        let key = Sdl.Event.get event Sdl.Event.keyboard_keycode in
        printf "Key: %s\n%!" (Sdl.get_key_name key);
        if key = Sdl.K.q then Caml.exit 0
      | _ -> ());
    Display.clear display Color.white;
    let base = Vec.create 150. 150. in
    Display.draw_line
      display
      ~width:20.
      base
      (Vec.add
         base
         (Vec.scale (Vec.unit_vec (Angle.of_degrees (Float.of_int !i))) 100.))
      (Color.rgb 250 50 50);
    Display.draw_line
      display
      ~width:5.
      (Vec.create (-150.) (-150.))
      (Vec.create (-250.) (-50.))
      (Color.rgb 10 250 10);
    Display.draw_image display image (Vec.create 0. 0.) theta ~scale:0.05;
    Display.present display;
    (* 5ms *)
    Sdl.delay 5l
  done;
  Display.Image.destroy image;
  Display.shutdown display;
  Caml.exit 0

let () = main ()
