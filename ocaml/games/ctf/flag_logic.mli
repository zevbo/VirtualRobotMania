open Virtuality2d

val flag : unit -> Body.t
val flag_protector : Body.t -> Body.t
val gen_updater : State.t -> World.updater
