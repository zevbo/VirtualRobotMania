open Core_kernel
open Virtuality2d
open Geo_graph
open Geo
open Tsdl

let fps = 50.

let main () =
  let elastic = Material.create ~energy_ret:1. in
  let scale = 0.5 in
  let shape = Shape.create_rect (150. *. scale) (112. *. scale) elastic in
  let robot = Body.create ~m:1. ~ang_intertia:1. ~average_r:5. shape in
  let robot = Body.apply_com_impulse robot (Vec.create 50. 0.) in
  let display = Display.init ~w:500 ~h:500 ~title:"test" in
  let world = ref (World.of_bodies [ robot ]) in
  let image =
    Display.Image.of_bmp_file display "../../../images/test-robot.bmp"
  in
  let event = Sdl.Event.create () in
  while true do
    if Sdl.poll_event (Some event)
    then (
      match Sdl.Event.enum (Sdl.Event.get event Sdl.Event.typ) with
      | `Key_up ->
        let key = Sdl.Event.get event Sdl.Event.keyboard_keycode in
        printf "Key: %s\n%!" (Sdl.get_key_name key);
        if key = Sdl.K.q then Caml.exit 0
      | _ -> ());
    Display.clear display Color.white;
    Display.draw_image
      ~scale
      display
      image
      (List.nth_exn (!world).bodies 0).pos
      (Geo.Angle.of_radians robot.angle);
    world := World.advance (!world) (1. /. fps);
    Display.present display;
    Sdl.delay (Int32.of_float (1000. /. fps));
  done;
  ()

let () = main ()
