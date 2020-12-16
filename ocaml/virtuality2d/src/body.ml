open! Geo
open! Base

type t =
  { shape : Shape.t
  ; m : float
  ; pos : Vec.t
  ; v : Vec.t
  ; angle : float
  ; omega : float
  ; ground_drag_c : float
  ; ground_fric_s_c : float
  ; ground_fric_k_c : float
  ; air_drag_c : float
  ; max_speed : float
  ; max_omega : float
  }
[@@deriving sexp_of]

let no_max_speed = -1.

let create
    ?(pos = Vec.origin)
    ?(v = Vec.origin)
    ?(angle = 0.)
    ?(omega = 0.)
    ?(ground_drag_c = 0.)
    ?(ground_fric_k_c = 0.)
    ?(ground_fric_s_c = 0.)
    ?(air_drag_c = 0.)
    ?(max_speed = no_max_speed)
    ?(max_omega = no_max_speed)
    ~m
    shape
  =
  { shape
  ; m
  ; pos
  ; v
  ; angle
  ; omega
  ; ground_drag_c
  ; ground_fric_k_c
  ; ground_fric_s_c
  ; air_drag_c
  ; max_speed
  ; max_omega
  }

(* format is a, b, c, discriminant, discriminant_leniance *)
exception Negatrive_discriminant of float * float * float * float * float

let quadratic_formula
    ?(discriminant_leniance = 0.)
    ?(allow_imaginary = false)
    a
    b
    c
    use_plus
  =
  if Float.equal a 0.
  then -.b /. c
  else (
    let discriminant = (b *. b) -. (4. *. a *. c) in
    let reset_discriminant =
      Float.(
        -.discriminant_leniance < discriminant && discriminant_leniance < 0.)
    in
    let adjusted_discriminant =
      if reset_discriminant then 0. else discriminant
    in
    if Float.(adjusted_discriminant < 0.) && not allow_imaginary
    then
      raise
        (Negatrive_discriminant
           (a, b, c, adjusted_discriminant, discriminant_leniance));
    let numerator =
      (if use_plus then ( +. ) else ( -. )) (-.b) (Float.sqrt discriminant)
    in
    numerator /. (2. *. a))

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  ; edge_1 : Edge.t
  ; edge_2 : Edge.t
  }
[@@deriving sexp_of]

let angular_inertia_of t = t.shape.inertia_over_mass *. t.m
let average_r_of t = t.shape.average_r

let get_edges_w_global_pos t =
  let to_global_pos t (ls : Line_like.segment Line_like.t) =
    Line_like.shift (Line_like.rotate ls t.angle) t.pos
  in
  let global_edges =
    List.map t.shape.edges ~f:(fun edge ->
        { edge with ls = to_global_pos t edge.ls })
  in
  global_edges

let intersections t1 t2 =
  (* create and do_intersect in Line_like and use here *)
  List.filter_map
    (List.cartesian_product
       (get_edges_w_global_pos t1)
       (get_edges_w_global_pos t2))
    ~f:(fun (e1, e2) ->
      match Line_like.intersection e1.ls e2.ls with
      | Some pt ->
        Some
          { pt
          ; energy_ret = Material.energy_ret_of e1.material e2.material
          ; edge_1 = e1
          ; edge_2 = e2
          }
      | None -> None)

let closest_dist_to_corner inter (edge : Edge.t) =
  let flip_points = Line_like.flip_points_of edge.ls in
  let dists =
    List.map flip_points ~f:(fun flip_point -> Vec.dist inter.pt flip_point)
  in
  Float.min (List.nth_exn dists 0) (List.nth_exn dists 1)

let momentum_of t = Vec.scale t.v t.m
let angular_momentum_of t = t.omega *. angular_inertia_of t

let apply_com_impulse t impulse =
  { t with v = Vec.add t.v (Vec.scale impulse (1. /. t.m)) }

(* Pure angular_impulse in this case means no net impulse on the com *)
let apply_pure_angular_impulse t angular_impulse =
  { t with omega = t.omega +. (angular_impulse /. angular_inertia_of t) }

let apply_impulse t impulse rel_force_pos =
  let t = apply_com_impulse t impulse in
  let angle = Vec.angle_with_origin impulse rel_force_pos in
  let r = Vec.mag rel_force_pos in
  let angular_impulse = Vec.mag impulse *. r *. Float.sin angle in
  apply_pure_angular_impulse t angular_impulse

let apply_impulse_w_global_pos t impulse pos =
  apply_impulse t impulse (Vec.sub pos t.pos)

let apply_force t force rel_force_pos dt =
  apply_impulse t (Vec.scale force dt) rel_force_pos

let apply_force_w_global_pos t force pos dt =
  apply_impulse t (Vec.scale force dt) (Vec.sub pos t.pos)

(* Currently assuming that friction/drag act essentially indepenedintly on
   angular and tangential velocity even though that is not the case However, to
   determine if friction is static or kinetic, we did that with angular and
   tangential velocity at the same time *)
let del_v_from_fric fric_c = fric_c *. Consts.dt

let del_omega_from_fric t fric_c =
  fric_c *. average_r_of t *. (t.m /. angular_inertia_of t) *. Consts.dt

let apply_tangnetial_forces t =
  let del_v_from_fric_s = del_v_from_fric t.ground_fric_s_c in
  let del_omega_from_fric_s = del_omega_from_fric t t.ground_fric_s_c in
  if Float.(
       del_v_from_fric_s ** 2. > Vec.mag_sq t.v
       && del_omega_from_fric_s > t.omega)
  then { t with v = Vec.origin; omega = 0. }
  else t

let get_r t pt = Vec.sub pt t.pos

let get_v_pt t pt =
  let r = get_r t pt in
  let v_perp =
    Vec.scale
      (* rotating r by pi/2 *)
      (Vec.to_unit (Vec.rotate r (Float.pi /. 2.)))
      (t.omega *. Vec.mag r)
  in
  Vec.add t.v v_perp

let p_of t = Vec.scale t.v t.m

let ke_of t =
  (0.5 *. t.m *. Vec.mag_sq t.v)
  +. (0.5 *. angular_inertia_of t *. (t.omega **. 2.))

type collision =
  { t1 : t
  ; t2 : t
  ; impulse_pt : Vec.t
  ; t1_acc_angle : float
  ; impulse_mag : float
  ; debug : float
  }
[@@deriving sexp_of]

exception Unkown_collision_error of string

let _impulse_min_mag_cushion = 0.01

let rec get_collision_from_intersections t1 t2 intersections =
  (* Not sure how to handle when there are multiple intersections. For the
     moment, just choosing the first one *)
  (* calculations done as if the collision point on t1 is standing still *)
  match intersections with
  | [] ->
    Stdio.print_endline "(theoretically) self-resolving collision";
    None
  | inter :: tl ->
    let epsilon = 0.0001 in
    let r1 = get_r t1 inter.pt in
    let r2 = get_r t2 inter.pt in
    let v1 = get_v_pt t1 inter.pt in
    let v2 = get_v_pt t2 inter.pt in
    let corner_1_dist = closest_dist_to_corner inter inter.edge_1 in
    let corner_2_dist = closest_dist_to_corner inter inter.edge_2 in
    let is_edge_1_flat = Float.(corner_1_dist > corner_2_dist) in
    let flat_edge = if is_edge_1_flat then inter.edge_1 else inter.edge_2 in
    let force_angle = Line_like.angle_of flat_edge.ls +. (Float.pi /. 2.) in
    (* acc angle for the flat edge *)
    let flat_edge_acc_angle =
      let starting_point_w_buffer =
        Vec.add inter.pt (Vec.scale (Vec.unit_vec force_angle) epsilon)
      in
      let test_ray =
        Line_like.ray_of_point_angle starting_point_w_buffer force_angle
      in
      let t = if is_edge_1_flat then t1 else t2 in
      let is_hit (edge : Edge.t) =
        Option.is_some (Line_like.intersection edge.ls test_ray)
      in
      if List.length (List.filter ~f:is_hit (get_edges_w_global_pos t)) % 2 = 1
      then force_angle
      else force_angle +. Float.pi
    in
    let t1_acc_angle =
      if is_edge_1_flat
      then flat_edge_acc_angle
      else flat_edge_acc_angle +. Float.pi
    in
    let t2_acc_angle = t1_acc_angle -. Float.pi in
    let t1_acc_unit_vec = Vec.unit_vec t1_acc_angle in
    let t2_acc_unit_vec = Vec.unit_vec t2_acc_angle in
    (* perp velocity of the intersection points *)
    let s1 = Vec.dot v1 t2_acc_unit_vec in
    let s2 = Vec.dot v2 t2_acc_unit_vec in
    if Float.(s2 > s1)
    then
      (* This means that the collision points are moving away from each other
         natrually *)
      get_collision_from_intersections t1 t2 tl
    else (
      let ei = ke_of t1 +. ke_of t2 in
      (* the theta in torque = F * r * sin(theta). Need a better name *)
      let get_torque_theta_of r = t1_acc_angle -. Vec.angle_of r in
      let get_k_of t r =
        Vec.mag r *. Float.sin (get_torque_theta_of r) /. angular_inertia_of t
      in
      let k1 = get_k_of t1 r1 in
      let k2 = get_k_of t2 r2 in
      (* this calculation has to be wrong *)
      let delta_s_over_impulse t k =
        (1. /. t.m) +. ((k **. 2.) *. angular_inertia_of t)
      in
      let impulse_min_mag_denom =
        delta_s_over_impulse t1 k1 +. delta_s_over_impulse t2 k2
      in
      if Float.equal impulse_min_mag_denom 0.
      then
        raise (Unkown_collision_error "Got infinite minimum impulse magnitude");
      let impulse_min_mag = (s1 -. s2) /. impulse_min_mag_denom in
      let apply_impulse impulse_mag =
        let impulse_1 = Vec.scale t1_acc_unit_vec impulse_mag in
        let impulse_2 = Vec.scale t2_acc_unit_vec impulse_mag in
        ( apply_impulse_w_global_pos t1 impulse_1 inter.pt
        , apply_impulse_w_global_pos t2 impulse_2 inter.pt )
      in
      let t1_with_impulse_min, t2_with_impulse_min =
        apply_impulse impulse_min_mag
      in
      (* There's a def problem here because the v_pts aren't equal *)
      let get_v_pt t impulse_pt t1_acc_angle =
        Vec.dot (get_v_pt t impulse_pt) (Vec.unit_vec t1_acc_angle)
      in
      let debug = get_v_pt t2_with_impulse_min inter.pt t1_acc_angle in
      (* e_min is wrong *)
      let e_min_1 = ke_of t1_with_impulse_min in
      let e_min_2 = ke_of t2_with_impulse_min in
      let e_min = e_min_1 +. e_min_2 in
      let e_final = (inter.energy_ret *. (ei -. e_min)) +. e_min in
      assert (Float.(e_min < ei));
      (* Link to math:
         https://www.wolframalpha.com/input/?i=E+%3D+0.5%28m+*+%28v+%2B+x%2Fm%29%5E2+%2B+M+*+%28V+-+x%2FM%29%5E2+%2B+i+*+%28w+%2B+x+*+k%29%5E2+%2B+L+*+%28W+-+x+*+K%29%5E2%29%2C+solve+for+x *)
      let impulse_a =
        0.5
        *. ((angular_inertia_of t1 *. (k1 **. 2.))
           +. (angular_inertia_of t2 *. (k2 **. 2.))
           +. (1. /. t1.m)
           +. (1. /. t2.m))
      in
      let impulse_b =
        -.Float.abs
            ((angular_inertia_of t1 *. k1 *. t1.omega)
            -. (angular_inertia_of t2 *. k2 *. t2.omega))
        -. Float.abs (Vec.mag t1.v -. Vec.mag t2.v)
      in
      let impulse_c =
        (0.5
        *. ((t1.m *. Vec.mag_sq t1.v)
           +. (t2.m *. Vec.mag_sq t2.v)
           +. (angular_inertia_of t1 *. (t1.omega **. 2.))
           +. (angular_inertia_of t2 *. (t2.omega **. 2.))))
        -. e_final
      in
      Stdio.printf
        "a b c: %f, %f, %f, %f, %f\n"
        (angular_inertia_of t1 *. k1 *. t1.omega)
        (angular_inertia_of t2 *. k2 *. t2.omega)
        (Vec.mag t1.v)
        (Vec.mag t2.v)
        impulse_b;
      (* Not sure if it is always + for the +/- in the quad formula *)
      (* Otherwise seems that this is right *)
      let discriminant_leniance = 0.1 in
      let impulse_quadratic_formula =
        quadratic_formula ~discriminant_leniance impulse_a impulse_b impulse_c
      in
      let impulse_mag_with_plus = impulse_quadratic_formula true in
      (*let impulse_mag_with_minus = impulse_quadratic_formula false in let
        get_accuracy impulse_mag = let t1_final, t2_final = apply_impulse
        impulse_mag in let real_e_final = ke_of t1_final +. ke_of t2_final in
        Float.abs (real_e_final -. e_final) in let use_plus = Float.(
        get_accuracy impulse_mag_with_plus < get_accuracy
        impulse_mag_with_minus) in let impulse_mag = if use_plus then
        impulse_mag_with_plus else impulse_mag_with_minus in*)
      let impulse_mag = impulse_mag_with_plus in
      if Float.is_nan impulse_mag
      then
        raise
          (Unkown_collision_error
             (Printf.sprintf
                "Got nan impulse magnitude.\n\
                 DEBUG INFO\n\
                 Min impulse mag: %f\n\
                 a,b,c: %f, %f, %f\n"
                impulse_min_mag
                impulse_a
                impulse_b
                impulse_c));
      let t1_final, t2_final = apply_impulse impulse_mag in
      let check_t_final t =
        if Float.is_nan t.pos.x
        then raise (Unkown_collision_error "Got nan x post-collision")
        else if Float.is_nan t.pos.y
        then raise (Unkown_collision_error "Got nan y post-collision")
        else if Float.is_nan t.v.x
        then raise (Unkown_collision_error "Got nan v.x post-collision")
        else if Float.is_nan t.v.y
        then raise (Unkown_collision_error "Got nan v.y post-collision")
      in
      check_t_final t1;
      check_t_final t2;
      Some
        { t1 = t1_final
        ; t2 = t2_final
        ; impulse_pt = inter.pt
        ; t1_acc_angle
        ; impulse_mag
        ; debug
        })

let is_inert t = Float.(t.max_speed = 0. && t.max_omega = 0.)

let get_collision t1 t2 =
  if is_inert t1 && is_inert t2
  then None
  else (
    match intersections t1 t2 with
    | [] -> None
    | intersections -> get_collision_from_intersections t1 t2 intersections)

let advance t dt =
  { t with
    pos = Vec.add t.pos (Vec.scale t.v dt)
  ; angle = t.angle +. (t.omega *. dt)
  }

let collide_advance t1 t2 _dt =
  match get_collision t1 t2 with
  | None -> t1, t2
  | Some
      { t1; t2; impulse_pt = _; t1_acc_angle = _; impulse_mag = _; debug = _ }
    -> t1, t2

let collide t1 t2 = collide_advance t1 t2 0.

(* will collide two bodies, and advance them the amount for them to no longer be
   touching *)
(* the amount it advances them will be a multiple of dt, for calculation reasons *)
let collide_and_min_bounce t1 t2 dt =
  match get_collision t1 t2 with
  | None -> t1, t2
  | Some
      { t1; t2; impulse_pt = _; t1_acc_angle = _; impulse_mag = _; debug = _ }
    ->
    let rec advance_until_freed t1 t2 =
      if List.is_empty (intersections t1 t2)
      then t1, t2
      else advance_until_freed (advance t1 dt) (advance t2 dt)
    in
    advance_until_freed t1 t2

let apply_speed_restriction t =
  if (not Float.(t.max_speed = no_max_speed))
     && Float.(Vec.mag_sq t.v > t.max_speed **. 2.)
  then { t with v = Vec.scale t.v (t.max_speed /. Vec.mag t.v) }
  else t

let sign_to_float (sign : Sign.t) =
  match sign with
  | Zero -> 0.
  | Neg -> -1.
  | Pos -> 1.

let apply_omega_restriction t =
  if (not Float.(t.max_omega = no_max_speed))
     && Float.(Float.abs t.omega > t.max_omega)
  then { t with omega = t.max_omega *. sign_to_float (Float.sign_exn t.omega) }
  else t

let apply_restrictions t = apply_omega_restriction (apply_speed_restriction t)
