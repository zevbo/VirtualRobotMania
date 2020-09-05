type t = { bodies : Body.t list }

val collide_bodies : t -> t
val advance : t -> t
