open! Core
open! Async

(** The shapes of the functions here mostly matches the protocol, except for the
    [State.t] argument in the front. *)

type 'a bot_input := State.t -> Bot_name.t * 'a

(** Non-user functions *)

val init : unit -> State.t Deferred.t
val step : State.t -> unit -> unit
val enhance_border : State.t -> unit
val num_flags : State.t -> int

(** User actuator functions *)

val set_motors : (float * float) bot_input -> unit
val l_input : unit bot_input -> float
val r_input : unit bot_input -> float
val shoot_laser : unit bot_input -> unit
val boost : unit bot_input -> unit

(** User sensor fuctions *)

val angle_to_opp : unit bot_input -> float
val dist_to_opp : unit bot_input -> float
val angle_to_flag : unit bot_input -> float
val dist_to_flag : unit bot_input -> float
val get_angle : unit bot_input -> float
val get_opp_angle : unit bot_input -> float
val just_fired : unit bot_input -> bool
val laser_cooldown_left : unit bot_input -> int
val just_boosted : unit bot_input -> bool
val boosted_cooldown_left : unit bot_input -> int
