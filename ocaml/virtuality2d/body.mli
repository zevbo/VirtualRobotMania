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

val momentum_of : t -> Vec.t
val angular_momentum_of : t -> float
val apply_tangnetial_forces : t -> unit
val collide : t -> t -> unit
val apply_force : t -> Vec.t -> Vec.t -> unit
val apply_force_with_global_pos : t -> Vec.t -> Vec.t -> unit
