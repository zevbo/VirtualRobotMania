type t =
  { width : float
  ; height : float
  ; center : Vec.t
  }
  [@@deriving sexp_of]

val contains : t -> Vec.t -> bool
val get_corners : t -> Vec.t list
