open Virtuality2d
open Geo_graph
open Tsdl

let fps = 20.

let main () =
  let elastic = Material.create ~energy_ret:1. in
  let shape = Shape.create_rect 10. 10. elastic in
  let robot = Body.create shape 1. 1. 5. in
  let display = Display.init ~w:500 ~h:500 ~title:"test" in
  let _world = ref (World.of_bodies [ robot ]) in
  let image =
    Display.Image.of_bmp_file display "../../../images/test-robot.bmp"
  in
  while true do
    Display.draw_image
      ~scale:0.1
      display
      image
      robot.pos
      (Geo.Angle.of_radians robot.angle);
    (*world := World.advance (!world) (1. /. fps);*)
    Sdl.delay (Int32.of_float fps)
  done;
  ()

let () = main ()
