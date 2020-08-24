open! Geo

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

val create : Shape.t -> float -> float -> float -> t
val p_of : t -> Vec.t
val momentum_of : t -> Vec.t
val angular_momentum_of : t -> float
val apply_tangnetial_forces : t -> t
val collide : t -> t -> t * t
val apply_force : t -> Vec.t -> Vec.t -> t
val apply_force_w_global_pos : t -> Vec.t -> Vec.t -> t
