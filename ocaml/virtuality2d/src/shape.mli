open! Geo

type t =
  { edges : Edge.t list
  ; bounding_box : Rect.t
  }
[@@deriving sexp_of]

val create : Edge.t list -> t
val create_closed : Vec.t list -> Material.t -> t
val create_rect : float -> float -> ?com:Vec.t -> Material.t -> t
