type t = { bodies : Body.t list }

val collide_bodies : Body.t list -> Body.t list
val advance : t -> float -> t
