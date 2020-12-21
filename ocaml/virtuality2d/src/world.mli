open Base

module Id : sig
  type t [@@deriving sexp]

  include Comparable.S with type t := t

  val to_int : t -> int
  val of_int : int -> t
end

type t = { bodies : Body.t Map.M(Id).t } [@@deriving sexp_of]

val empty : t
val get_body_exn : t -> Id.t -> Body.t
val of_bodies : Body.t list -> t
val add_body : t -> Body.t -> t * Id.t
val set_body : t -> Id.t -> Body.t -> t
val advance : t -> dt:float -> t
val all_of_coll_group : t -> int -> (Id.t * Body.t) list
val remove_body : t -> Id.t -> t
