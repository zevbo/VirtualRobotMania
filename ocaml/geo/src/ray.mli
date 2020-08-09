type t =
  { pt_end : Vec.t
  ; pt_dir : Vec.t
  }
[@@deriving sexp]

val create : Vec.t -> Vec.t -> t
val to_ll : t -> t Line_like.t
val point_angle_form : Vec.t -> float -> t
val point_slope_form : Vec.t -> float -> t
