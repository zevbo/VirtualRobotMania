open Core_kernel
open Virtuality2d
open Geo_graph
open Geo
open Helpers

let name = "random-bodies-with-border"
let tps = 200.
let tpf = tps /. fps
let time_multiplier = 1.

let run () =
  let state = State.create () in
  let _elastic = Material.create ~energy_ret:1. in
  let standard_body = Material.create ~energy_ret:0.8 in
  let _inelastic = Material.create ~energy_ret:0.04 in
  let _scale = 0.5 in
  let frame_width = Float.of_int frame_width in
  let frame_height = Float.of_int frame_height in
  let border_width = 5. in
  let border_material = Material.create ~energy_ret:0.8 in
  let vertical_border_shape =
    Shape.create_standard_rect
      border_width
      frame_height
      ~material:border_material
  in
  let horizontal_border_shape =
    Shape.create_standard_rect
      frame_width
      border_width
      ~material:border_material
  in
  let create_border pos shape = Body.create ~m:Float.infinity ~pos shape in
  let border_1 =
    create_border (Vec.create (frame_width /. 2.) 0.) vertical_border_shape
  in
  let border_2 =
    create_border (Vec.create (frame_width /. -2.) 0.) vertical_border_shape
  in
  let border_3 =
    create_border (Vec.create 0. (frame_height /. 2.)) horizontal_border_shape
  in
  let border_4 =
    create_border (Vec.create 0. (frame_height /. -2.)) horizontal_border_shape
  in
  let robot_width = 50. in
  let robot_length = 75. in
  let create_random pos =
    let shape =
      Shape.create_standard_rect
        robot_length
        robot_width
        ~material:standard_body
    in
    let omega = Random.float_range (-0.3) 0.3 in
    let random_vel () = Random.float_range (-160.) 160. in
    let v = Vec.create (random_vel ()) (random_vel ()) in
    let angle = Random.float_range 0. (2. *. Float.pi) in
    Body.create ~m:1. ~pos ~v ~omega ~angle shape
  in
  (*let robot = Body.create ~m:1. ~ang_inertia:1. ~average_r:40. shape in let
    robot = Body.apply_com_impulse robot (Vec.create 50. 0.) in let robot_2 =
    Body.create ~m:1. ~ang_inertia:1. ~average_r:40. ~pos:(Vec.create 200. 10.)
    shape in*)
  let robot_positions =
    [ Vec.create 175. 175.
    ; Vec.create 175. (-175.)
    ; Vec.create (-175.) 175.
    ; Vec.create (-175.) (-175.)
    ; Vec.create 0. 0.
    ]
  in
  let robots = List.map robot_positions ~f:create_random in
  let borders = [ border_1; border_2; border_3; border_4 ] in
  let world = ref (World.of_bodies (List.append robots borders)) in
  let _image =
    Display.Image.of_bmp_file state.display "../../../images/test-robot.bmp"
  in
  let ignore_it _ = () in
  let draw_robot robot_n =
    let robot = List.nth_exn !world.bodies robot_n in
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
      ignore_it (List.map ~f:draw_robot (List.range 0 (List.length robots)));
      draw_robot 0;
      for _ = 0 to Int.of_float tpf do
        world := World.advance !world (time_multiplier /. (tpf *. fps))
      done)
