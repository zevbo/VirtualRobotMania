type t = 
    | Simple of {drag_c: float; fric_c: float}

val drag_c_of : t -> t -> float 
val fric_c_of : t -> t -> float