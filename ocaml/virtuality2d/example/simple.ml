open Core_kernel
open Virtuality2d
open Geo_graph_tsdl
open Geo
open Helpers

let name = "simple"
let tps = 200.
let tpf = tps /. fps
let time_multiplier = 1.

let run () =
  let state = State.create () in
  let elastic = Material.create ~energy_ret:0.8 in
  let _scale = 0.5 in
  let robot_width = 50. in
  let robot_length = 75. in
  let shape =
    Shape.create_standard_rect robot_length robot_width ~material:elastic
  in
  (*let robot = Body.create ~m:1. ~ang_inertia:1. ~average_r:40. shape in let
    robot = Body.apply_com_impulse robot (Vec.create 50. 0.) in let robot_2 =
    Body.create ~m:1. ~ang_inertia:1. ~average_r:40. ~pos:(Vec.create 200. 10.)
    shape in*)
  let robot =
    Body.create
      ~m:1.
      ~pos:(Vec.create (-50.) 0.)
      ~collision_group:0
      ~omega:0.1
      shape
  in
  let b2 =
    Body.create
      ~m:1.
      ~v:(Vec.create (-100.) 0.)
      ~pos:(Vec.create 100. 0.)
      ~angle:(-0.1)
      ~collision_group:0
      shape
  in
  let robot_2 = { b2 with angle = Float.pi /. 4.; pos = Vec.create 220.7 0. } in
  let world = ref (World.of_bodies [ robot; robot_2 ]) in
  let _image =
    Display.image_of_bmp_file state.display "../../../images/test-robot.bmp"
  in
  let draw_robot robot_n =
    let robot_n = World.Id.of_int robot_n in
    let robot = Map.find_exn !world.bodies robot_n in
    let half_length =
      Vec.rotate (Vec.create (robot_length /. 2.) 0.) robot.angle
    in
    Display.draw_line
      ~width:robot_width
      state.display
      (Vec.add robot.pos half_length)
      (Vec.sub robot.pos half_length)
      Color.black
  in
  sim_loop state (fun () ->
      draw_robot 0;
      draw_robot 1;
      for _ = 0 to Int.of_float tpf do
        world := World.advance !world ~dt:(time_multiplier /. (tpf *. fps))
      done)
