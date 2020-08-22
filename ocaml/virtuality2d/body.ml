open! Geo
open! Base

type t =
  { shape : Shape.t
  ; m : float
  ; ang_intertia : float (* for friction's effect on angular velocity *)
  ; average_r : float
  ; pos : Vec.t
  ; v : Vec.t
  ; omega : float
  ; ground_drag_c : float
  ; ground_fric_s_c : float
  ; ground_fric_k_c : float
  ; air_drag_c : float
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
  { t with v = Vec.add t.v (Vec.scale force (Consts.dt /. t.m)) }

(* Pure torque in this case means no net force on the com *)
let apply_pure_torque t torque =
  { t with omega = t.omega +. (torque *. Consts.dt /. t.m) }

let apply_force t force rel_force_pos =
  let t = apply_com_force t force in
  let angle = Vec.angle_with_origin force rel_force_pos in
  let r = Vec.mag rel_force_pos in
  let torque = Vec.mag force *. r *. Float.sin angle in
  apply_pure_torque t torque

let apply_force_w_global_pos t force pos =
  apply_force t force (Vec.sub pos t.pos)

let apply_impulse t impulse rel_force_pos =
  apply_force t (Vec.scale impulse (1. /. Consts.dt)) rel_force_pos

let apply_impulse_w_global_pos t impulse pos =
  apply_impulse t impulse (Vec.sub pos t.pos)

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
  then { t with v = Vec.origin; omega = 0. }
  else t

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

let p_of t = Vec.scale t.v t.m

let ke_of t =
  (0.5 *. t.m *. Vec.mag_sq t.v) +. (0.5 *. t.ang_intertia *. (t.omega **. 2.))

let collide t1 t2 =
  (* Not sure how to handle when there are multiple intersections. For the moment, just choosing the first one *)
  match Shape.intersections t1.shape t2.shape with
  | [] -> t1, t2
  | inter :: _ ->
    (* calculations done as if the collision point on t1 is standing still *)
    let epsilon = 0.0001 in
    let mtotal = t1.m +. t2.m in
    let r1 = get_r inter.pt t1 in
    let r2 = get_r inter.pt t2 in
    let v1 = get_v_pt inter.pt t1 in
    let v2 = get_v_pt inter.pt t2 in
    let corner_1_dist = Shape.closest_dist_to_corner inter inter.edge_1 in
    let corner_2_dist = Shape.closest_dist_to_corner inter inter.edge_2 in
    let is_edge_1_flat = Float.(corner_1_dist > corner_2_dist) in
    let flat_edge = if is_edge_1_flat then inter.edge_1 else inter.edge_2 in
    let force_angle = Line_like.angle_of flat_edge.ls +. (Float.pi /. 2.) in
    let flat_edge_acc_angle =
      let starting_point_w_buffer =
        Vec.add inter.pt (Vec.scale (Vec.unit_vec force_angle) epsilon)
      in
      let test_ray =
        Line_like.ray_of_point_angle starting_point_w_buffer force_angle
      in
      let shape = if is_edge_1_flat then t1.shape else t2.shape in
      let is_hit (edge : Edge.t) =
        Option.is_some (Line_like.intersection edge.ls test_ray)
      in
      if List.length (List.filter ~f:is_hit shape.edges) % 2 = 1
      then force_angle +. Float.pi
      else force_angle
    in
    let ei = ke_of t1 +. ke_of t2 in
    (* perp velocity of the intersection points *)
    let flat_edge_acc_unit_vec = Vec.unit_vec flat_edge_acc_angle in
    let s1 = Vec.dot v1 flat_edge_acc_unit_vec in
    let s2 = Vec.dot v2 flat_edge_acc_unit_vec in
    let get_k_of t r =
      Vec.mag r *. Float.sin (Vec.angle_of r) /. t.ang_intertia
    in
    let k1 = get_k_of t1 r1 in
    let k2 = get_k_of t2 r2 in
    (* Note: this can be made faster if we use Vec.mag_sq *)
    let impulse_min_mag =
      (s1 -. s2)
      /. ((1. /. t1.m)
         +. (1. /. t2.m)
         +. (Vec.mag r1 *. k1)
         +. (Vec.mag r2 *. k2))
    in
    let apply_impulse impulse_mag =
      let impulse_1 = Vec.scale flat_edge_acc_unit_vec impulse_min_mag in
      let impulse_2 = Vec.rotate impulse_1 Float.pi in
      ( apply_impulse_w_global_pos t1 impulse_1 inter.pt
      , apply_impulse_w_global_pos t2 impulse_2 inter.pt )
    in
    let t1_with_impulse_min, t2_with_impulse_min =
      apply_impulse impulse_min_mag
    in
    let e_min_1 = ke_of t1_with_impulse_min in
    let e_min_2 = ke_of t2_with_impulse_min in
    let e_min = e_min_1 +. e_min_2 in
    let e_final = (inter.energy_ret *. (ei -. e_min)) +. e_min in
    (* Link to math: https://www.wolframalpha.com/input/?i=E+%3D+0.5%28m+*+%28v+%2B+x%2Fm%29%5E2+%2B+M+*+%28V+%2B+x%2FM%29%5E2+%2B+i+*+%28w+%2B+x+*+k%29%5E2+%2B+L+*+%28W+%2B+x+*+K%29%5E2%29%2C+solve+for+x *)
    let impulse_a =
      0.5
      *. ((t1.ang_intertia *. (k1 **. 2.))
         +. (t2.ang_intertia *. (k2 **. 2.))
         +. (1. /. t1.m)
         +. (1. /. t2.m))
    in
    let impulse_b =
      (t1.ang_intertia *. k1 *. t1.omega)
      +. (t2.ang_intertia *. k2 *. t2.omega)
      +. Vec.mag t1.v
      +. Vec.mag t2.v
    in
    let impulse_c =
      (0.5
      *. ((t1.m *. Vec.mag_sq t1.v)
         +. (t2.m *. Vec.mag_sq t2.v)
         +. (t1.ang_intertia *. (t1.omega **. 2.))
         +. (t2.ang_intertia *. (t2.omega **. 2.))))
      -. e_final
    in
    (* Not sure if it is always + for the +/- in the quad formula *)
    let impulse_mag = quadratic_formula impulse_a impulse_b impulse_c true in
    apply_impulse impulse_mag
