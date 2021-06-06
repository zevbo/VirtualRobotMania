open Virtuality2d

val laser : bot:Body.t -> Body.t
val update : State.t -> unit
val restock_laser : State.t -> World.Id.t -> unit
val shoot_laser : State.t -> World.Id.t -> unit
val current_power : State.t -> float -> int
