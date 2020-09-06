(** [energy_ret] is number between 0. and 1. that says how elastic a collision
    is. 0. is perfectly inelastic, 1. is perfectly elastic.*)

type t = { energy_ret : float } [@@deriving sexp_of]

val create : energy_ret:float -> t

(** Determines how elastic a collision is between the two provided materials. *)
val energy_ret_of : t -> t -> float
