open Base

module Id : sig
  type t

  include Comparable.S with type t := t

  val to_int : t -> int
  val of_int : int -> t
end

type t =
  { bodies : Body.t Map.M(Id).t
  ; updaters : (Body.t -> t -> Body.t) Map.M(Id).t
  }

type updater := Body.t -> t -> Body.t

val empty : t
val null_updater : updater
val of_bodies : Body.t list -> t
val of_bodies_and_updaters : (Body.t * updater) list -> t
val add_body : t -> ?updater:updater -> Body.t -> t * Id.t
val advance : t -> dt:float -> t
