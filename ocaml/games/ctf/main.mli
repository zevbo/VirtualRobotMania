open! Core_kernel
open! Async_kernel

(** The shapes of the functions here mostly matches the protocol, except for the
    [State.t] argument in the front. *)

(** Non-user functions *)

type ('a, 'b) bot_func := State.t -> Bot_name.t * 'a -> 'b
type ('a, 'b) state_func := State.t -> 'a -> 'b

val init : log_s:(Sexp.t -> unit) -> State.t Deferred.t
val step : State.t -> unit -> unit Deferred.t
val just_returned_flag : (unit, bool) state_func
val just_killed : (unit, bool) state_func
val enhance_border : (unit, unit) state_func
val setup_shield : (unit, unit) state_func
val num_flags : (unit, int) state_func

(** User actuator functions *)

val set_motors : (float * float, unit) bot_func
val l_input : (unit, float) bot_func
val r_input : (unit, float) bot_func
val load_laser : (unit, unit) bot_func
val restock_laser : (unit, unit) bot_func
val shoot_laser : (unit, unit) bot_func
val boost : (unit, unit) bot_func

(** User sensor fuctions *)

val angle_to_opp : (unit, float) bot_func
val dist_to_opp : (unit, float) bot_func
val angle_to_flag : (unit, float) bot_func
val dist_to_flag : (unit, float) bot_func
val get_angle : (unit, float) bot_func
val get_opp_angle : (unit, float) bot_func
val just_fired : (unit, bool) bot_func
val laser_cooldown_left : (unit, int) bot_func
val just_boosted : (unit, bool) bot_func
val boost_cooldown_left : (unit, int) bot_func
val looking_dist : (float, float) bot_func
val offense_has_flag : (unit, bool) bot_func
val next_laser_power : (unit, int) bot_func
