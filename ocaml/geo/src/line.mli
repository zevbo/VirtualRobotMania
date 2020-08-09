type t =
  { pt1 : Vec.t
  ; pt2 : Vec.t
  }
[@@deriving sexp]

val create : Vec.t -> Vec.t -> Line_like.line Line_like.t
val point_angle_form : Vec.t -> float -> Line_like.line Line_like.t
val point_slope_form : Vec.t -> float -> Line_like.line Line_like.t
