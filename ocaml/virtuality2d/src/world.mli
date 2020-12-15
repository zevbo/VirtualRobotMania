type t = { bodies : Body.t list }

val create : unit -> t
val of_bodies : Body.t list -> t 
val add_body : t -> Body.t -> t

val collide_bodies : Body.t list -> Body.t list
val advance : t -> float -> t
