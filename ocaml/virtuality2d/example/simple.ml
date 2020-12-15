open Core_kernel
open Virtuality2d
open Geo_graph
open Geo
open Helpers

let name = "simple"

let run () =
  let state = State.create () in
  let elastic = Material.create ~energy_ret:1. in
  let scale = 0.5 in
  let shape = Shape.create_rect (150. *. scale) (112. *. scale) elastic in
  let robot = Body.create ~m:1. ~ang_intertia:1. ~average_r:5. shape in
  let robot = Body.apply_com_impulse robot (Vec.create 50. 0.) in
  let world = ref (World.of_bodies [ robot ]) in
  let image =
    Display.Image.of_bmp_file state.display "../../../images/test-robot.bmp"
  in
  sim_loop state (fun () ->
      Display.draw_image
        ~scale:1.
        state.display
        image
        (List.nth_exn !world.bodies 0).pos
        (Geo.Angle.of_radians robot.angle);
      world := World.advance !world (1. /. fps))
