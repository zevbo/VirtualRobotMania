open Core_kernel
open Virtuality2d
open Geo_graph
open Geo
open Tsdl
open Helpers

let name = "simple"

let run () =
  let state = State.create () in
  let elastic = Material.create ~energy_ret:1. in
  let shape = Shape.create_rect 10. 10. elastic in
  let robot = Body.create shape 1. 1. 5. in
  let robot = Body.apply_com_impulse robot (Vec.create 2. 0.) in
  let world = ref (World.of_bodies [ robot ]) in
  let image =
    Display.Image.of_bmp_file state.display "../../../images/test-robot.bmp"
  in
  sim_loop state (fun () ->
      Display.draw_image
        ~scale:1.
        state.display
        image
        robot.pos
        (Geo.Angle.of_radians robot.angle);
      world := World.advance !world (1. /. fps);
      Sdl.delay (Int32.of_float (1000. /. fps)))
