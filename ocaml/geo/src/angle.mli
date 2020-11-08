open! Base

type t = private float

val of_radians : float -> t
val of_degrees : float -> t
val to_radians : t -> float
val to_degrees : t -> float
val sin : t -> float
val cos : t -> float
val atan2 : float -> float -> t
val atan : float -> t
val acos : float -> t
val asin : float -> t
