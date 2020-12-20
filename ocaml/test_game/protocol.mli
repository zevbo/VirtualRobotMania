open! Core
module Call := Csexp_rpc.Call

(** RPCs for interacting with the game engine. *)

val step : (unit, unit) Call.t
val add_bot : (unit, int) Call.t
val load_bot_image : (int * string, unit) Call.t
