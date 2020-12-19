open! Base
open! Stdio
open Geo
open Geo_graph
open Tsdl

let oe = function
  | Ok _ as x -> x
  | Error (`Msg s) -> Error (Error.of_string s)

let ok_exn x = Or_error.ok_exn (oe x)
let radians_of_degrees x = x *. Float.pi /. 180.

let main () =
  let display = Display.init ~w:1000 ~h:800 ~title:"Image Display" in
  let image = Display.Image.of_bmp_file display "SignalsandThreads-3000.bmp" in
  let event = Sdl.Event.create () in
  let i = ref 0 in
  while true do
    Int.incr i;
    let theta = Float.of_int !i *. 1.0 *. Float.pi /. 180. in
    if Sdl.poll_event (Some event)
    then (
      match Sdl.Event.enum (Sdl.Event.get event Sdl.Event.typ) with
      | `Key_up ->
        let key = Sdl.Event.get event Sdl.Event.keyboard_keycode in
        printf "Key: %s\n%!" (Sdl.get_key_name key);
        if key = Sdl.K.q then Caml.exit 0
      | _ -> ());
    Display.clear display Color.white;
    let line w v1 v2 c = Display.draw_line display ~width:w v1 v2 c in
    line
      20.
      (Vec.scale
         (Vec.unit_vec (radians_of_degrees (-2. *. Float.of_int !i)))
         150.)
      (Vec.scale (Vec.unit_vec (radians_of_degrees (Float.of_int !i))) 100.)
      (Color.rgb 250 50 50);
    line
      5.
      (Vec.create (-150.) (-150.))
      (Vec.create (-250.) (-50.))
      (Color.rgb 10 250 10);
    Display.draw_image_wh
      display
      image
      ~center:(Vec.create 200. 0.)
      ~w:300.
      ~h:100.
      ~angle:(theta *. 2.);
    Display.draw_image
      display
      image
      ~center:(Vec.create 0. 0.)
      ~angle:theta
      ~scale:0.05;
    Display.present display;
    (* 5ms *)
    Sdl.delay 5l
  done;
  Display.Image.destroy image;
  Display.shutdown display;
  Caml.exit 0

let () = main ()
