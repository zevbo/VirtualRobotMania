(** This is the primary interface of the game. *)

(** Create a new bot. The game will put your bot...somewhere. Eventually, we'll
    need to specify an image to go with it. *)
val add_bot : unit -> int

(** Steps the simulation, blocking for a frame's worth of time minus the time
    between this call to [step] and the previous one. *)
val step : unit -> unit

(** Requests that we load an image for the bot of the number in question.
    Doesn't do anything if the file can't be found. Can be run for bots that
    haven't yet been added. *)
val load_bot_image : int -> string -> unit
