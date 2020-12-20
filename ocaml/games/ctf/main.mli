val init : unit -> State.t
val step : State.t -> unit
val set_motors : State.t -> float -> float -> unit
val l_input : State.t -> float
val r_input : State.t -> float
val make_on_offense_bot : State.t -> unit
val make_off_offense_bot : State.t -> unit
