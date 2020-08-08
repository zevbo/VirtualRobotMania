type t = {x : float; y : float}

val magSq : t -> float
val mag : t -> float
val scale : t -> float -> t
val add : t -> t -> t
val sub : t -> t -> t
val to_unit : t -> t
val collinear : t -> t -> t -> bool
val distSq : t -> t -> float
val dist : t -> t -> float
val equals : ?epsilon:float -> t -> t -> bool