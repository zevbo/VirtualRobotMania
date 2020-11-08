open! Base

type t = private float [@@deriving sexp]

include Comparable.S with type t := t

module O : sig
  val ( + ) : t -> t -> t
  val ( * ) : t -> float -> t
  val ( - ) : t -> t -> t
  val ( / ) : t -> float -> t

  include Comparable.Infix with type t := t
end

val zero : t
val add : t -> t -> t
val sub : t -> t -> t
val scale : t -> float -> t
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

(** pi, in radians *)
val pi : t
