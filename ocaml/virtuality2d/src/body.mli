open! Geo

type mass =
  | Inertial of float
  | Static
[@@deriving sexp_of]

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
  ; curr_forces : force list
  }
[@@deriving sexp_of]

(** Shape -> Mass -> Angular Inertia -> Average_r *)
val create
  :  ?pos:Vec.t
  -> ?v:Vec.t
  -> ?angle:float
  -> ?omega:float
  -> ?ground_drag_c:float
  -> ?ground_fric_k_c:float
  -> ?ground_fric_s_c:float
  -> ?air_drag_c:float
  -> ?max_speed:float
  -> ?max_omega:float
  -> m:float
  -> Shape.t
  -> t

val momentum_of : t -> Vec.t
val ang_momentum_of : t -> float
val apply_com_impulse : t -> Vec.t -> t
val apply_pure_ang_impulse : t -> float -> t
val apply_impulse : t -> Vec.t -> Vec.t -> t
val apply_impulse_w_global_pos : t -> Vec.t -> Vec.t -> t
val exert_force : t -> Vec.t -> Vec.t -> t
val exert_force_w_global_pos : t -> Vec.t -> Vec.t -> t
val exert_ground_friction : t -> t
val exert_drag : t -> ?medium_v:Vec.t -> ?v_exponent:float -> float -> t
val exert_pure_torque : t -> float -> t
val apply_all_forces : ?reset_forces:bool -> t -> float -> t
val get_edges_w_global_pos : t -> Edge.t list
val get_v_pt : t -> Vec.t -> Vec.t

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  ; edge_1 : Edge.t
  ; edge_2 : Edge.t
  }
[@@deriving sexp_of]

val intersections : ?dt:float -> t -> t -> intersection list

type collision =
  { t1 : t
  ; t2 : t
  ; impulse_pt : Vec.t
  ; t1_acc_angle : float
  ; impulse_mag : float
  ; debug : float
  }
[@@deriving sexp_of]

val get_collision : float -> t -> t -> collision option

(** Takes two bodies, returns the two bodies in the same order as a pair once
    they have collided. If they are not touching, the same bodies will be
    returned *)
val collide : float -> t -> t -> t * t

val advance : ?apply_forces:bool -> t -> dt:float -> t
val ang_inertia_of : t -> mass
val get_mass : t -> default:float -> float
val get_ang_inertia : t -> default:float -> float
val average_r_of : t -> float
val apply_restrictions : t -> t
