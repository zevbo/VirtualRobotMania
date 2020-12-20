open Virtuality2d
open Geo

let apply_motor_force
    (body : Body.t)
    ~dt
    ~bot_height
    ~force_over_input
    ~air_resistance_c
    ~side_fric_k
    l_input
    r_input
  =
  let y_to_pos y = Vec.add (Vec.rotate (Vec.create 0. y) body.angle) body.pos in
  let left_pos = y_to_pos (bot_height /. 2.) in
  let right_pos = y_to_pos (-.bot_height /. 2.) in
  let get_v_pt pt = Vec.rotate (Body.get_v_pt body pt) (-.body.angle) in
  let left_v_pt = get_v_pt left_pos in
  let right_v_pt = get_v_pt right_pos in
  let get_par_acc (v_pt : Vec.t) input =
    (force_over_input *. input) -. (air_resistance_c *. v_pt.x)
  in
  let m = Body.get_mass body ~default:0. in
  let get_perp_acc (v_pt : Vec.t) =
    let max_force = -.Float.copy_sign (side_fric_k *. m) v_pt.y in
    if dt *. Float.abs max_force > Float.abs v_pt.y
    then -.v_pt.y /. dt
    else max_force
  in
  let get_acc v_pt input =
    Vec.create (get_par_acc v_pt input) (get_perp_acc v_pt)
  in
  let right_acc = get_acc right_v_pt r_input in
  let left_acc = get_acc left_v_pt l_input in
  let total_alpha = 2. *. (right_acc.x -. left_acc.x) /. bot_height in
  let pure_force =
    Vec.scale (Vec.rotate (Vec.add right_acc left_acc) body.angle) m
  in
  let pure_torque = total_alpha *. Body.get_ang_inertia body ~default:0. in
  let body = Body.exert_force body pure_force Vec.origin in
  let body = Body.exert_pure_torque body pure_torque in
  body
