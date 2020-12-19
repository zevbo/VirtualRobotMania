type t = { bodies : world_body list }

and updater = Body.t -> t -> Body.t

and world_body =
  { body : Body.t
  ; updaters : updater list
  }
[@@deriving fields]

val create_world_body : Body.t -> updater list -> world_body
val create : unit -> t
val of_bodies : Body.t list -> t
val add_body : t -> ?updaters:updater list -> Body.t -> t
val of_world_bodies : world_body list -> t
val add_world_body : t -> world_body -> t
val collide_bodies : Body.t list -> Body.t list
val advance : t -> float -> t
