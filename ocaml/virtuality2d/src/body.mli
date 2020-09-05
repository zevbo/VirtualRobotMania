open! Geo

type t =
  { shape : Shape.t
  ; m : float
  ; ang_intertia : float (* for friction's effect on angular velocity *)
  ; average_r : float
  ; pos : Vec.t
  ; v : Vec.t
  ; angle : float
  ; omega : float
  ; ground_drag_c : float
  ; ground_fric_s_c : float
  ; ground_fric_k_c : float
  ; air_drag_c : float
  }
[@@deriving sexp_of]

val create
  :  Shape.t
  -> float
  -> float
  -> ?pos:Vec.t
  -> ?v:Vec.t
  -> ?angle:float
  -> ?omega:float
  -> ?ground_drag_c:float
  -> ?ground_fric_k_c:float
  -> ?ground_fric_s_c:float
  -> ?air_drag_c:float
  -> float
  -> t

val p_of : t -> Vec.t
val momentum_of : t -> Vec.t
val angular_momentum_of : t -> float
val apply_tangnetial_forces : t -> t
val apply_com_impulse : t -> Vec.t -> t
val apply_pure_angular_impulse : t -> float -> t
val apply_impulse : t -> Vec.t -> Vec.t -> t
val apply_impulse_w_global_pos : t -> Vec.t -> Vec.t -> t
val apply_force : t -> Vec.t -> Vec.t -> float -> t
val apply_force_w_global_pos : t -> Vec.t -> Vec.t -> float -> t
val get_edges_w_global_pos : t -> Edge.t list
val get_v_pt : t -> Vec.t -> Vec.t

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  ; edge_1 : Edge.t
  ; edge_2 : Edge.t
  }
[@@deriving sexp_of]

val intersections : t -> t -> intersection list
val closest_dist_to_corner : intersection -> Edge.t -> float

type collision =
  { t1 : t
  ; t2 : t
  ; impulse_pt : Vec.t
  ; t1_acc_angle : float
  ; impulse_mag : float
  ; debug : float
  }
[@@deriving sexp_of]

val get_collision : t -> t -> collision Option.t
val collide : t -> t -> t * t
val advance : t -> float -> t
val collide_advance : t -> t -> float -> t * t
