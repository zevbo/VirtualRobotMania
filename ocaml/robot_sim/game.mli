(** This is the primary interface of the game. *)

(** Create a new bot. The game will put your bot...somewhere. Eventually, we'll
    need to specify an image to go with it. *)
val create_bot : unit -> int

(** Creates the window, starts up the display. *)
val start : unit -> unit

(** Steps the simulation *)
val step : unit -> unit
