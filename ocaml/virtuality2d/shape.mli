open! Geo

type t =
  { edges : Edge.t list
  ; bounding_box : Square.t
  }

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  }

val intersections : t -> t -> intersection list
