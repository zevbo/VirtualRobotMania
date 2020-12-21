open Virtuality2d

type t = private
  { mutable last_fire_ts : float
  ; mutable l_input : float
  ; mutable r_input : float
  }

val create : unit -> t
val defense_bot : unit -> Body.t
val update : t -> dt:float -> Body.t -> Body.t

(** {2 Setters} *)

val set_l_input : t -> float -> unit
val set_r_input : t -> float -> unit
val set_last_fire_ts : t -> float -> unit
