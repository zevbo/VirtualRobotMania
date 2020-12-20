open Virtuality2d

val defense_bot : unit -> Body.t
val gen_updater : State.Defense_bot.t -> float -> Body.t -> World.t -> Body.t
