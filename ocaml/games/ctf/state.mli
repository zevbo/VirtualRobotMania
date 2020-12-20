type t

val create : unit -> t
val step : t -> unit
val set_motors : t -> float -> float -> unit
val l_input : t -> float
val r_input : t -> float
