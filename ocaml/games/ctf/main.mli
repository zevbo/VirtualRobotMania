open! Core_kernel
open! Async_kernel

(** The shapes of the functions here mostly matches the protocol, except for the
    [State.t] argument in the front. *)

module Make (Display : Geo_graph.Display_intf.S) : sig
  (** Non-user functions *)

  module State := State.Make(Display)

  val init : root:string -> State.t
  val step : State.t -> unit -> unit
  val just_returned_flag : State.t -> bool
  val just_killed : State.t -> bool
  val enhance_border : State.t -> unit
  val setup_shield : State.t -> unit
  val num_flags : State.t -> int

  type ('a, 'b) bot_func := State.t -> Bot_name.t * 'a -> 'b

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
end
