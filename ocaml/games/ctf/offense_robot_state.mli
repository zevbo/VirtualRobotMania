open Virtuality2d

type t =
  { mutable l_input : float
  ; mutable r_input : float
  }

val create : unit -> t
val gen_updater : t -> float -> Body.t -> World.t -> Body.t
