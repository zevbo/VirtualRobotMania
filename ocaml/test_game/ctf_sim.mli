(** This is the primary interface of the game. *)

(** Steps the simulation, blocking for a frame's worth of time minus the time
    between this call to [step] and the previous one. *)
val step : unit -> unit

(** Sets the input to the motors *)
val set_motors : float -> float -> unit

(** Get's current input to left motor *)
val l_input : unit -> float

(** Get's current input to right motor *)
val r_input : unit -> float

(** Shoots laser if on offense bot *)
val shoot_laser : unit -> unit
