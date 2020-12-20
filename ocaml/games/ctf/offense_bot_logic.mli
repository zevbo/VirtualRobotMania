open Virtuality2d

val offense_bot : unit -> Body.t
val gen_updater : State.Offense_bot.t -> float -> Body.t -> World.t -> Body.t
