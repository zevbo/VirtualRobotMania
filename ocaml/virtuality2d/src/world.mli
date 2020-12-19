open Base

module Id : sig
  type t

  include Comparable.S with type t := t

  val to_int : t -> int
  val of_int : int -> t
end

type t = { bodies : world_body Map.M(Id).t }

and updater = Body.t -> t -> Body.t

and world_body =
  { body : Body.t
  ; updater : updater
  }
[@@deriving fields]

val create_world_body : ?updater:updater -> Body.t -> world_body
val create : unit -> t
val of_world_bodies : world_body list -> t
val of_bodies : Body.t list -> t
val add_body : t -> ?updater:updater -> Body.t -> t
val add_world_body : t -> world_body -> t
val advance : t -> dt:float -> t
