open! Core
open! Async

val init : unit -> State.t Deferred.t
val step : State.t -> unit -> unit
val set_motors : State.t -> Bot_name.t * (float * float) -> unit
val l_input : State.t -> Bot_name.t * unit -> float
val r_input : State.t -> Bot_name.t * unit -> float
val shoot_laser : State.t -> Bot_name.t * unit -> unit
val opp_angle : State.t -> Bot_name.t * unit -> float
val opp_dist : State.t -> Bot_name.t * unit -> float
val boost : State.t -> Bot_name.t * unit -> unit
val enhance_border : State.t -> unit
val num_flags : State.t -> int
