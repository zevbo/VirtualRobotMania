open! Geo
open! Base

type mass =
  | Inertial of float
  | Static
[@@deriving sexp_of]

(* this doesn't necessarily correspond to mechanics types such as normal,
   frictional and spring. Its only for functional differences in their
   application to a body *)
type normal_force =
  { force : Vec.t
  ; rel_force_pos : Vec.t
  }
[@@deriving sexp_of]

type drag_force =
  { drag_c : float
  ; v_exponent : float
  ; medium_v : Vec.t
  }
[@@deriving sexp_of]

type force =
  | Normal of normal_force
  | Pure_torque of float
  | Ground_frictional
  | Drag of drag_force
[@@deriving sexp_of]

type t =
  { shape : Shape.t
  ; m : mass
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
  ; collision_group : int
  ; black_list : Set.M(Int).t
  ; curr_forces : force list
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
    ?(black_list = [])
    ~collision_group
    ~m
    shape
  =
  let m = if Float.(m = Float.infinity) then Static else Inertial m in
  let cmp = Set.comparator_s (Set.empty (module Int)) in
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
  ; black_list = Set.of_list cmp black_list
  ; collision_group
  ; curr_forces = []
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
  then -.c /. b
  else (
    let discriminant = (b *. b) -. (4. *. a *. c) in
    let ignore_imaginary = Float.(-.discriminant_leniance < discriminant) in
    if Float.(discriminant < 0.)
       && (not allow_imaginary)
       && not ignore_imaginary
    then
      raise
        (Negatrive_discriminant (a, b, c, discriminant, discriminant_leniance));
    let discriminant_sqrt = Float.sqrt discriminant in
    let real_discrim_value =
      if Float.is_nan discriminant_sqrt then 0. else discriminant_sqrt
    in
    let numerator =
      (if use_plus then ( +. ) else ( -. )) (-.b) real_discrim_value
    in
    numerator /. (2. *. a))

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  ; edge_1 : Edge.t
  ; edge_2 : Edge.t
  }
[@@deriving sexp_of]

let ang_inertia_from_mass t m = t.shape.inertia_over_mass *. m

let ang_inertia_of t =
  match t.m with
  | Inertial m -> Inertial (ang_inertia_from_mass t m)
  | Static -> Static

let mass_reciprocal m =
  match m with
  | Inertial m -> 1. /. m
  | Static -> 0.

let decode_mass m ~default =
  match m with
  | Inertial m -> m
  | Static -> default

let get_mass t ~default = decode_mass t.m ~default
let get_ang_inertia t ~default = decode_mass (ang_inertia_of t) ~default
let average_r_of t = t.shape.average_r

let apply_speed_restriction t =
  if (not Float.(t.max_speed = no_max_speed))
     && Float.(Vec.mag_sq t.v > t.max_speed **. 2.)
  then { t with v = Vec.scale t.v (t.max_speed /. Vec.mag t.v) }
  else t

let apply_omega_restriction t =
  if (not Float.(t.max_omega = no_max_speed))
     && Float.(Float.abs t.omega > t.max_omega)
  then { t with omega = Float.copysign t.max_omega t.omega }
  else t

let apply_restrictions t = apply_omega_restriction (apply_speed_restriction t)

let get_edges_w_global_pos t =
  let to_global_pos t (ls : Line_like.segment Line_like.t) =
    Line_like.shift (Line_like.rotate ls t.angle) t.pos
  in
  let global_edges =
    List.map t.shape.edges ~f:(fun edge ->
        { edge with ls = to_global_pos t edge.ls })
  in
  global_edges

let is_inwards t pt angle =
  let test_ray = Line_like.ray_of_point_angle pt angle in
  let is_hit (edge : Edge.t) =
    Option.is_some (Line_like.intersection edge.ls test_ray)
    && not (Line_like.on_line edge.ls pt)
  in
  List.length (List.filter ~f:is_hit (get_edges_w_global_pos t)) % 2 = 1

let parallel_turn_left (e1 : Edge.t) (e2 : Edge.t) =
  let connector =
    Line_like.line (Line_like.get_p1 e1.ls) (Line_like.get_p1 e2.ls)
  in
  let dif =
    Vec.normalize_angle
      (Line_like.angle_of connector -. Line_like.angle_of e1.ls)
  in
  if Float.O.(dif = 0.) then 0. else if Float.O.(dif > 0.) then 1. else -1.

let closest_dist_to_corner inter (edge : Edge.t) =
  let flip_points = Line_like.flip_points_of edge.ls in
  let dists =
    List.map flip_points ~f:(fun flip_point ->
        flip_point, Vec.dist inter.pt flip_point)
  in
  let sorted =
    List.sort dists ~compare:(fun (_pt1, dist1) (_pt2, dist2) ->
        Float.compare dist1 dist2)
  in
  match sorted with
  | closest_pd :: _tl -> closest_pd
  | [] ->
    raise
      (Failure
         "Somehow there was only one flip point of an edge in \
          closest_dist_to_corner")

let momentum_of t = Vec.scale t.v (get_mass t ~default:0.)
let ang_momentum_of t = t.omega *. get_ang_inertia t ~default:0.

let apply_com_impulse t impulse =
  { t with v = Vec.add t.v (Vec.scale impulse (mass_reciprocal t.m)) }

(* Pure ang_impulse in this case means no net impulse on the com *)
let apply_pure_ang_impulse t ang_impulse =
  { t with
    omega = t.omega +. (ang_impulse *. mass_reciprocal (ang_inertia_of t))
  }

let apply_impulse t impulse rel_force_pos =
  let t = apply_com_impulse t impulse in
  let angle = Vec.angle_with_origin impulse rel_force_pos in
  let r = Vec.mag rel_force_pos in
  let ang_impulse = Vec.mag impulse *. r *. Float.sin angle in
  apply_pure_ang_impulse t ang_impulse

let apply_impulse_w_global_pos t impulse pos =
  apply_impulse t impulse (Vec.sub pos t.pos)

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

(* *)
let exert_force t (force : Vec.t) rel_force_pos =
  let normal_force = Normal { force; rel_force_pos } in
  { t with curr_forces = normal_force :: t.curr_forces }

let exert_force_w_global_pos t force pos =
  let normal_force = Normal { force; rel_force_pos = Vec.sub pos t.pos } in
  { t with curr_forces = normal_force :: t.curr_forces }

let exert_pure_torque t torque =
  { t with curr_forces = Pure_torque torque :: t.curr_forces }

(* Currently assuming that friction/drag act essentially indepenedintly on
   angular and tangential velocity even though that is not the case. However, to
   determine if friction is static or kinetic, we did that with angular and
   tangential velocity at the same time *)
let fric_force_mag normal fric_c = fric_c *. normal

let ground_fric_force_mag t fric_c =
  fric_force_mag (Consts.g *. get_mass t ~default:0.) fric_c

let ground_fric_torque_mag t fric_c =
  fric_c *. average_r_of t *. Consts.g *. get_mass t ~default:0.

let is_static_friction ?(dt = 0.) t =
  Vec.equals ~epsilon:0. t.v Vec.origin
  || Float.(
       Vec.mag_sq t.v <= dt *. ground_fric_force_mag t t.ground_fric_s_c
       && abs t.omega <= dt *. ground_fric_torque_mag t t.ground_fric_s_c)

let apply_ground_friction_with_c t dt fric_c =
  let t =
    apply_com_impulse
      t
      (Vec.scale (Vec.to_unit t.v) (-.dt *. ground_fric_force_mag t fric_c))
  in
  let t =
    if Float.(t.omega = 0.)
    then t
    else
      apply_pure_ang_impulse
        t
        (-.Float.copysign (ground_fric_torque_mag t fric_c *. dt) t.omega)
  in
  t

let apply_ground_friction t dt =
  if is_static_friction t ~dt
  then apply_ground_friction_with_c t dt t.ground_fric_s_c
  else apply_ground_friction_with_c t dt t.ground_fric_k_c

let apply_normal_force dt t force =
  match force with
  | Normal normal_force ->
    let t =
      apply_impulse
        t
        (Vec.scale normal_force.force dt)
        normal_force.rel_force_pos
    in
    (*Stdio.printf "force: (%f, %f). v: (%f, %f)\n" normal_force.force.x
      normal_force.force.y t.v.x t.v.y;*)
    t
  | _ -> t

let apply_pure_torque dt t force =
  match force with
  | Pure_torque torque -> apply_pure_ang_impulse t (dt *. torque)
  | _ -> t

let apply_ground_frictional_force dt t force =
  match force with
  | Ground_frictional -> apply_ground_friction t dt
  | _ -> t

(* k and n are for df/dt = kv^n *)
(*let apply_drag_force_at_point ?(is_closed = true) dt t drag_force force_pt
  length inwards_angle = let v_pt = get_v_pt { t with v = Vec.sub t.v
  drag_force.medium_v } force_pt in assert (Float.(abs v_pt.x < 100000.)); let
  force_vec = Vec.unit_vec inwards_angle in let v_opposed = Vec.dot v_pt
  (Vec.scale force_vec (-1.)) in if Float.(v_opposed <= 0.) && is_closed then t
  else ( let force_mag = length *. drag_force.drag_c *. (Float.abs v_opposed **.
  drag_force.v_exponent) in let force = Vec.scale force_vec force_mag in
  apply_impulse_w_global_pos t (Vec.scale force dt) force_pt)

  let apply_drag_force_on_side dt drag_force del_theta t (edge : Edge.t) = let
  p1 = Line_like.get_p1 edge.ls in let p2 = Line_like.get_p2 edge.ls in let
  angle_1 = Vec.angle_of p1 in let angle_2 = Vec.angle_of p2 in let perp_angle =
  Line_like.angle_of edge.ls +. (Float.pi /. 2.) in let is_perp_inwards =
  is_inwards t (Vec.mid_point p1 p2) perp_angle in let inwards_angle = if
  is_perp_inwards then perp_angle else perp_angle +. Float.pi in let num_samples
  = Float.round_up (Float.abs (angle_2 -. angle_1) /. del_theta) in let
  del_l_mag = Vec.dist p1 p2 /. (num_samples +. 1.) in let del_l = Vec.scale
  (Vec.to_unit (Vec.sub p2 p1)) del_l_mag in let starting_pt = Vec.add p1
  (Vec.scale del_l 0.5) in let num_point_to_vec num_pt = let pt = Vec.add
  starting_pt (Vec.scale del_l (Float.of_int num_pt)) in let param =
  Line_like.param_of_proj_point edge.ls pt in let real_pt =
  Line_like.param_to_point edge.ls param in assert (Line_like.on_line
  (Line_like.line p1 p2) real_pt); assert (Line_like.on_line edge.ls real_pt);
  Vec.add t.pos real_pt in let handle_point t pt = apply_drag_force_at_point dt
  t drag_force pt del_l_mag inwards_angle in let points = List.map (List.range 0
  (Int.of_float num_samples)) ~f:num_point_to_vec in List.fold points ~init:t
  ~f:handle_point*)

let apply_drag_force _dt t _force = t

(* match force with | Drag drag_force -> List.fold t.shape.edges ~init:t
   ~f:(apply_drag_force_on_side dt drag_force standard_del_theta) | _ -> t*)

let apply_all_forces ?(reset_forces = true) t dt =
  let force_applications =
    [ apply_normal_force
    ; apply_pure_torque
    ; apply_ground_frictional_force
    ; apply_drag_force
    ]
  in
  let use_force_application t force_application =
    let t = List.fold t.curr_forces ~init:t ~f:(force_application dt) in
    t
  in
  let t = List.fold force_applications ~init:t ~f:use_force_application in
  if reset_forces then { t with curr_forces = [] } else t

let exert_ground_friction t =
  { t with curr_forces = Ground_frictional :: t.curr_forces }

let exert_drag t ?(medium_v = Vec.origin) ?(v_exponent = 1.) drag_c =
  Stdio.printf "Drag force not currently supported\n";
  let drag_force = { drag_c; v_exponent; medium_v } in
  { t with curr_forces = Drag drag_force :: t.curr_forces }

let advance ?(apply_forces = true) t ~dt =
  let t = if apply_forces then apply_all_forces t dt else t in
  { t with
    pos = Vec.add t.pos (Vec.scale t.v dt)
  ; angle = t.angle +. (t.omega *. dt)
  }

let _parallel_intersection
    (e1_before : Edge.t)
    (e2_before : Edge.t)
    (e1_after : Edge.t)
    (e2_after : Edge.t)
  =
  (* this is probably gonna slow us down because we already calculated these
     intersections *)
  (* we can almost certianly eliminate it *)
  let inter_1 = lazy (Line_like.intersection e1_before.ls e2_before.ls) in
  let inter_2 = lazy (Line_like.intersection e1_after.ls e2_after.ls) in
  if Float.O.(
       parallel_turn_left e1_before e2_before
       = parallel_turn_left e1_after e2_after)
     || Option.is_none (force inter_1)
     || Option.is_none (force inter_2)
  then None
  else (
    let get_param_bound (edge : Edge.t) is_p1 =
      Line_like.param_of_proj_point
        edge.ls
        ((if is_p1 then Line_like.get_p1 else Line_like.get_p2) edge.ls)
    in
    let param_bound_11 = get_param_bound e1_after true in
    let param_bound_21 = get_param_bound e1_after false in
    let param_bound_12 = get_param_bound e2_after true in
    let param_bound_22 = get_param_bound e2_after false in
    let params =
      [ param_bound_11; param_bound_12; param_bound_21; param_bound_22 ]
    in
    let sorted_params = List.sort params ~compare:Float.compare in
    (* These exns are safe because params we already know has length 3 *)
    assert (List.length sorted_params = 4);
    let param_min = List.nth_exn sorted_params 1 in
    let param_max = List.nth_exn sorted_params 2 in
    let min_pt = Line_like.param_to_point e1_after.ls param_min in
    let max_pt = Line_like.param_to_point e1_after.ls param_max in
    let pt = Vec.mid_point min_pt max_pt in
    Some
      { pt
      ; energy_ret = Material.energy_ret_of e1_after.material e2_after.material
      ; edge_1 = e1_after
      ; edge_2 = e2_after
      })

let intersections ?(allow_blacklist = false) ?(dt = 0.) t1 t2 =
  (* create and do_intersect in Line_like and use here *)
  let _void = dt in
  if (Set.mem t1.black_list t2.collision_group
     || Set.mem t2.black_list t1.collision_group)
     && not allow_blacklist
  then []
  else (
    let normal_intersections =
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
    in
    (*if Float.O.(dt = 0.) then normal_intersections else ( let advance =
      advance ~apply_forces:false ~dt:(0. -. dt) in let get_edge_pairs t = let
      t_prev = advance t in let zipped = List.zip (get_edges_w_global_pos
      t_prev) (get_edges_w_global_pos t) in match zipped with | Ok zipped ->
      zipped | Unequal_lengths -> raise (Failure "Get_edges_w_global_pos
      returned different lengths for t and \ t_prev. If you got here, something
      really weird has happened.") in let parallel_intersections =
      List.filter_map (List.cartesian_product (get_edge_pairs t1)
      (get_edge_pairs t2)) ~f:(fun ((e1_before, e1_after), (e2_before,
      e2_after)) -> match parallel_intersection e1_before e2_before e1_after
      e2_after with | Some inter -> Some inter | None -> None) in List.append
      normal_intersections parallel_intersections)*)
    normal_intersections)

let ke_of t =
  (0.5 *. get_mass t ~default:0. *. Vec.mag_sq t.v)
  +. (0.5 *. get_ang_inertia t ~default:0. *. (t.omega **. 2.))

type collision =
  { t1 : t
  ; t2 : t
  ; impulse_pt : Vec.t
  ; t1_acc_angle : float
  ; impulse_mag : float
  ; debug : float
  }
[@@deriving sexp_of]

let is_static t =
  match t.m with
  | Static -> true
  | _ -> false

exception Unkown_collision_error of string

let rec get_collision_from_intersections t1 t2 intersections =
  (* Not sure how to handle when there are multiple intersections. For the
     moment, just choosing the first one *)
  (* calculations done as if the collision point on t1 is standing still *)
  match intersections with
  | [] -> None
  | inter :: tl ->
    let r1 = get_r t1 inter.pt in
    let r2 = get_r t2 inter.pt in
    let corner_1 = closest_dist_to_corner inter inter.edge_1 in
    let corner_2 = closest_dist_to_corner inter inter.edge_2 in
    let is_edge_1_flat = Float.(snd corner_1 > snd corner_2) in
    let flat_edge = if is_edge_1_flat then inter.edge_1 else inter.edge_2 in
    let sharp_corner = if is_edge_1_flat then fst corner_2 else fst corner_1 in
    let max_min_escape_v = 300. in
    let min_escape_v =
      Float.min
        ((Line_like.dist_sq_to_pt flat_edge.ls sharp_corner **. 2.) /. 100.)
        max_min_escape_v
    in
    (*let min_escape_v = if is_static t1 || is_static t2 then min_escape_v else
      0. in*)
    let force_angle = Line_like.angle_of flat_edge.ls +. (Float.pi /. 2.) in
    (* acc angle for the flat edge *)
    let flat_edge_acc_angle =
      let t = if is_edge_1_flat then t1 else t2 in
      let is_inwards = is_inwards t inter.pt force_angle in
      if is_inwards then force_angle else force_angle +. Float.pi
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
    let get_s t = Vec.dot (get_v_pt t inter.pt) t2_acc_unit_vec in
    let s_1 = get_s t1 in
    let s_2 = get_s t2 in
    let required_dif = s_1 -. s_2 +. min_escape_v in
    if Float.(required_dif <= 0.)
    then
      (* This means that the collision points are moving away from each other
         natrually *)
      get_collision_from_intersections t1 t2 tl
    else (
      let ei = ke_of t1 +. ke_of t2 in
      (* the theta in torque = F * r * sin(theta). Need a better name *)
      let get_torque_theta_of r = t1_acc_angle -. Vec.angle_of r in
      let get_k_of t r =
        Vec.mag r
        *. Float.sin (get_torque_theta_of r)
        *. mass_reciprocal (ang_inertia_of t)
      in
      let k1 = get_k_of t1 r1 in
      let k2 = get_k_of t2 r2 in
      (* this calculation has to be wrong *)
      let delta_s_over_impulse t k =
        match t.m with
        | Inertial m -> (1. /. m) +. ((k **. 2.) *. ang_inertia_from_mass t m)
        | Static -> 0.
      in
      let impulse_min_mag_denom =
        delta_s_over_impulse t1 k1 +. delta_s_over_impulse t2 k2
      in
      if Float.equal impulse_min_mag_denom 0.
      then
        raise (Unkown_collision_error "Got infinite minimum impulse magnitude");
      let impulse_min_mag = required_dif /. impulse_min_mag_denom in
      let apply_impulse impulse_mag =
        let impulse_1 = Vec.scale t1_acc_unit_vec impulse_mag in
        let impulse_2 = Vec.scale t2_acc_unit_vec impulse_mag in
        ( apply_impulse_w_global_pos t1 impulse_1 inter.pt
        , apply_impulse_w_global_pos t2 impulse_2 inter.pt )
      in
      let t1_with_impulse_min, t2_with_impulse_min =
        apply_impulse impulse_min_mag
      in
      let debug = get_s t2_with_impulse_min in
      (* e_min is wrong *)
      let e_min_1 = ke_of t1_with_impulse_min in
      let e_min_2 = ke_of t2_with_impulse_min in
      let e_min = e_min_1 +. e_min_2 in
      let e_final =
        Float.max e_min (((inter.energy_ret **. 2.) *. (ei -. e_min)) +. e_min)
      in
      (*assert (Float.(e_min < ei));*)
      (* Link to math:
         https://www.wolframalpha.com/input/?i=2E+%3D+m+*+%28%28v+%2B+x%2Fm%29%5E2+%2B+s%5E2%29+%2B+M+*+%28%28V+-+x%2FM%29%5E2+%2B+s%5E2%29+%2B+i+*+%28w+%2B+x+*+k%29%5E2+%2B+L+*+%28W+-+x+*+K%29%5E2%2C+solve+for+x *)
      (* we can default to 0 when static because k & omega will be 0 *)
      let get_ang_inertia = get_ang_inertia ~default:0. in
      let adjusted_v t = Vec.rotate t.v (-.t1_acc_angle) in
      let adj_v_1 = adjusted_v t1 in
      let adj_v_2 = adjusted_v t2 in
      let par_1 = adj_v_1.x in
      let par_2 = adj_v_2.x in
      let impulse_a =
        (get_ang_inertia t1 *. (k1 **. 2.))
        +. (get_ang_inertia t2 *. (k2 **. 2.))
        +. mass_reciprocal t1.m
        +. mass_reciprocal t2.m
      in
      (* we have to make sure impulse_b is negative becauase we are looking for
         the impulse magnitude, must be positive *)
      let impulse_b =
        -2.
        *. Float.abs
             ((get_ang_inertia t1 *. k1 *. t1.omega)
             -. (get_ang_inertia t2 *. k2 *. t2.omega)
             +. par_1
             -. par_2)
      in
      (* we can default to 0 when static because v will be 0 *)
      let get_mass = get_mass ~default:0. in
      let impulse_c =
        (get_mass t1 *. Vec.mag_sq t1.v)
        +. (get_mass t2 *. Vec.mag_sq t2.v)
        +. (get_ang_inertia t1 *. (t1.omega **. 2.))
        +. (get_ang_inertia t2 *. (t2.omega **. 2.))
        -. (2. *. e_final)
      in
      let discriminant_leniance =
        0.5 *. Float.max (get_mass t1) (get_mass t2)
      in
      let impulse_quadratic_formula =
        quadratic_formula ~discriminant_leniance impulse_a impulse_b impulse_c
      in
      let impulse_mag_with_plus = impulse_quadratic_formula true in
      let impulse_mag_with_minus = impulse_quadratic_formula false in
      let get_error impulse_mag =
        let t1_final, t2_final = apply_impulse impulse_mag in
        let real_e_final = ke_of t1_final +. ke_of t2_final in
        (real_e_final /. e_final) -. 1.
      in
      let use_plus =
        Float.(
          get_error impulse_mag_with_plus < get_error impulse_mag_with_minus)
      in
      let impulse_mag =
        if use_plus then impulse_mag_with_plus else impulse_mag_with_minus
      in
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
      Some
        { t1 = t1_final
        ; t2 = t2_final
        ; impulse_pt = inter.pt
        ; t1_acc_angle
        ; impulse_mag
        ; debug
        })

let get_collision dt t1 t2 =
  if is_static t1 && is_static t2
  then None
  else (
    match intersections t1 t2 ~dt with
    | [] -> None
    | intersections -> get_collision_from_intersections t1 t2 intersections)

let collide dt t1 t2 =
  match get_collision dt t1 t2 with
  | None -> t1, t2
  | Some
      { t1; t2; impulse_pt = _; t1_acc_angle = _; impulse_mag = _; debug = _ }
    -> t1, t2
