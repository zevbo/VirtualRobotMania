open Base

type t

module Id : sig
  type t

  include Comparable.S with type t := t

  val to_int : t -> int
  val of_int : int -> t
end

val create : unit -> t
val add_body : t -> Body.t -> Id.t * t
val remove_body : t -> Id.t -> t
val bodies : t -> Body.t Map.M(Id).t
val advance : t -> dt:float -> t
