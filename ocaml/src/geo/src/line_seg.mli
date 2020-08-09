type t = {pt1: Vec.t; pt2: Vec.t}
[@@deriving sexp]

val create : Vec.t -> Vec.t -> t
val to_ll : t -> Line_like.t