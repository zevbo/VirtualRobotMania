open! Geo

type t =
  { mutable shape : Shape.t
  ; mutable m : float
  ; mutable ang_intertia : float (* for friction's effect on angular velocity *)
  ; mutable average_r : float
  ; mutable pos : Vec.t
  ; mutable v : Vec.t
  ; mutable omega : float
  ; mutable ground_drag_c : float
  ; mutable ground_fric_s_c : float
  ; mutable ground_fric_k_c : float
  ; mutable air_drag_c : float
  }

let quadratic_formula a b c use_plus =
  let discriminant = (b *. b) -. (4. *. a *. c) in
  let numerator =
    (if use_plus then (+.) else (-.)) (-.b) (Float.sqrt discriminant)
  in
  numerator /. (2. *. a)

let momentum_of t = Vec.scale t.v t.m
let angular_momentum_of t = t.omega *. t.ang_intertia

let apply_com_force t force =
  t.v <- Vec.add t.v (Vec.scale force (Consts.dt /. t.m))

(* Pure torque in this case means no net force on the com *)
let apply_pure_torque t torque =
  t.omega <- t.omega +. (torque *. Consts.dt /. t.m)

let apply_force t force rel_force_pos =
  apply_com_force t force;
  let angle = Vec.angle_with_origin force rel_force_pos in
  let r = Vec.mag rel_force_pos in
  let torque = Vec.mag force *. r *. Float.sin angle in
  apply_pure_torque t torque

let apply_force_with_global_pos t force pos =
  apply_force t force (Vec.sub pos t.pos)

let apply_impulse t impulse rel_force_pos =
  apply_force t (Vec.scale impulse (1. /. Consts.dt)) rel_force_pos

(* 
  Currently assuming that friction/drag act essentially indepenedintly on angular and tangential velocity
    even though that is not the case
  However, to determine if friction is static or kinetic, we did that with angular and tangential velocity
    at the same time 
*)
let del_v_from_fric fric_c = fric_c *. Consts.dt

let del_omega_from_fric t fric_c =
  fric_c *. t.average_r *. (t.m /. t.ang_intertia) *. Consts.dt

let apply_tangnetial_forces t =
  let del_v_from_fric_s = del_v_from_fric t.ground_fric_s_c in
  let del_omega_from_fric_s = del_omega_from_fric t t.ground_fric_s_c in
  if Float.(
       del_v_from_fric_s ** 2. > Vec.mag_sq t.v
       && del_omega_from_fric_s > t.omega)
  then (
    t.v <- Vec.origin;
    t.omega <- 0.)

let get_r pt t = Vec.sub pt t.pos

let get_v_pt pt t =
  let r = get_r pt t in
  let v_perp =
    Vec.scale
      (* rotating r by pi/2 *)
      (Vec.to_unit (Vec.rotate r (Float.pi *. 2.)))
      (t.omega *. Vec.mag r)
  in
  Vec.add t.v v_perp

let collide t1 t2 =
  (* Not sure how to handle when there are multiple intersections. For the moment, just choosing the first one *)
  let intersections = Shape.intersections t1.shape t2.shape in
  if List.length intersections > 0
  then (
    (* calculations done as if the collision point on t1 is standing still *)
    let epsilon = 0.00001 in
    let inter = List.nth intersections 0 in
    let mtotal = t1.m +. t2.m in
    let v1 = get_v_pt inter.pt t1 in
    let v2 = get_v_pt inter.pt t2 in
    let corner_1_dist = Shape.closest_dist_to_corner inter inter.edge_1 in
    let corner_2_dist = Shape.closest_dist_to_corner inter inter.edge_2 in
    let flat_edge =
      if corner_1_dist > corner_2_dist then inter.edge_1 else inter.edge_2
    in
    let force_angle = Line_like.angle_of flat_edge +. (Float.pi /. 2.) in
    let vPerp1i = Vec.sub t2.v t1.v in
    ())
