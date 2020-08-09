type t =
  { pt1 : Vec.t
  ; pt2 : Vec.t
  }
[@@deriving sexp]

let create pt1 pt2 =
  let t = { pt1; pt2 } in
  Line_like.create_w_flip_points
    Line_like.Kind.Line t.pt1 (Vec.sub t.pt2 t.pt1) []

let point_angle_form pt angle =
  create pt (Vec.add (Vec.rotate (Vec.create 1. 0.) angle) pt)

let point_slope_form pt slope = point_angle_form pt (Float.atan slope)
