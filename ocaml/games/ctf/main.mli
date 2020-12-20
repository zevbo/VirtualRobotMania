val init : unit -> State.t
val step : State.t -> unit
val set_motors : State.t -> float -> float -> unit
val l_input : State.t -> float
val r_input : State.t -> float
