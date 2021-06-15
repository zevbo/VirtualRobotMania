open Virtuality2d

type t =
  { mutable has_flag : bool
  ; mutable num_flags : int
  ; mutable last_boost : float
  ; mutable last_shield : float
  ; mutable lives : int
  ; mutable l_input : float
  ; mutable r_input : float
  ; mutable last_kill : float
  ; mutable last_flag_return : float
  ; mutable times_killed : int
  }

val create : unit -> t
val body : Body.t
val shield : Body.t
val boost : Body.t
val update : t -> dt:float -> Body.t -> float -> Body.t
val update_shield : Body.t -> Body.t -> Body.t
val update_boost : Body.t -> Body.t -> t -> Body.t
val remove_live : t -> ?num_lives:int -> Body.t -> float -> Body.t

(** {2 setters} *)

val set_has_flag : t -> bool -> unit
val set_l_input : t -> float -> unit
val set_r_input : t -> float -> unit
