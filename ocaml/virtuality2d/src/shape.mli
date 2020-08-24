open! Geo

type t =
  { edges : Edge.t list
  ; bounding_box : Square.t
  }
[@@deriving sexp_of]

val create : Edge.t list -> t

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  ; edge_1 : Edge.t
  ; edge_2 : Edge.t
  }
[@@deriving sexp_of]

val intersections : t -> t -> intersection list
val closest_dist_to_corner : intersection -> Edge.t -> float