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
  (* TODO: add angle_between *)
  let angle = Vec.angle_between rel_force_pos force in
  let r = Vec.mag rel_force_pos in
  let torque = Vec.mag force *. r *. Float.sin angle in
  apply_pure_torque t torque

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

let collide t1 t2 =
  (* Not sure how to handle when there are multiple intersections. For the moment, just choosing the first one *)
  let intersections = Shape.intersections t1.shape t2.shape in
  if List.length intersections > 0
  then (
    (* calculations done as if t1 is standing still *)
    let epsilon = 0.00001 in
    let inter = List.nth intersections 0 in
    let mtotal = t1.m +. t2.m in
    let v2i = Vec.sub t2.v t1.v in
    let s2i = Vec.mag v2i in
    let p = s2i *. t2.m in
    let ei = 0.5 *. t2.m *. s2i *. s2i in
    let emin = 0.5 *. p *. p /. mtotal in
    let ef = (inter.energy_ret *. (ei -. emin)) +. emin in
    (* The following is for calculating the solution to the guadratic formula of s1f *)
    let s1f_a = t1.m *. (t1.m +. t2.m) in
    let s1f_b = -2. *. p *. t1.m in
    let s1f_c = (2. *. t2.m *. ef) -. (p *. p) in
    (* I don't know if we should be passing true or false to s1f.
       But what I do know is that one of them will come out the same as the initial s1f (which is 0),
          so that's how I'm doing it *)
    let s1f_calculator = quadratic_formula s1f_a s1f_b s1f_c in
    let s1f_true = s1f_calculator true in
    let s1f_false = s1f_calculator false in
    let s1f =
      if Float.(Float.abs s1f_true < epsilon) then s1f_true else s1f_false
    in
    let s2f = (p -. (t1.m *. s1f)) /. t2.m in
    ())
