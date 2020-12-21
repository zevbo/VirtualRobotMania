open Virtuality2d

type t = private
  { mutable has_flag : bool
  ; mutable lives : int
  ; mutable l_input : float
  ; mutable r_input : float
  }

val create : unit -> t
val body : Body.t
val update : t -> dt:float -> Body.t -> Body.t
val remove_live : t -> ?num_lives:int -> Body.t -> Body.t

(** {2 setters} *)

val set_has_flag : t -> bool -> unit
val set_l_input : t -> float -> unit
val set_r_input : t -> float -> unit
