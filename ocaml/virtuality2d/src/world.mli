open Base

module Id : sig
  type t

  include Comparable.S with type t := t

  val to_int : t -> int
  val of_int : int -> t
end

type t =
  { bodies : Body.t Map.M(Id).t
  ; updaters : updater Map.M(Id).t
  }
[@@deriving sexp_of]

and updater = Id.t -> Body.t -> t -> Body.t

val empty : t
val null_updater : updater
val of_bodies : Body.t list -> t
val of_bodies_and_updaters : (Body.t * updater) list -> t
val add_body : t -> ?updater:updater -> Body.t -> t * Id.t
val advance : t -> dt:float -> t
val all_of_coll_group : t -> int -> (Id.t * Body.t) list
val remove_body : t -> Id.t -> t
