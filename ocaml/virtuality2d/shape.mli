open! Geo

type t =
  { edges : Edge.t list
  ; bounding_box : Square.t
  }

val intersections : t -> t -> Vec.t list
