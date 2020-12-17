open! Geo

type t =
  { edges : Edge.t list
  ; bounding_box : Rect.t
  ; average_r : float
  ; inertia_over_mass : float
  }
[@@deriving sexp_of]

val create
  :  edges:Edge.t list
  -> average_r:float
  -> inertia_over_mass:float
  -> t

val create_closed
  :  points:Vec.t list
  -> material:Material.t
  -> average_r:float
  -> inertia_over_mass:float
  -> t

val create_rect
  :  float
  -> float
  -> ?com:Vec.t
  -> material:Material.t
  -> average_r:float
  -> inertia_over_mass:float
  -> t

val create_standard_rect
  :  ?com:Vec.t
  -> float
  -> float
  -> material:Material.t
  -> t
