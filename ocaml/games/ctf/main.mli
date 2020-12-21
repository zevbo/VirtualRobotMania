open! Core
open! Async

val init : unit -> State.t Deferred.t
val step : State.t -> unit
val set_motors : State.t -> float -> float -> unit
val l_input : State.t -> float
val r_input : State.t -> float
val use_offense_bot : State.t -> unit
val use_defense_bot : State.t -> unit
val shoot_laser : State.t -> unit
val boost : State.t -> unit
