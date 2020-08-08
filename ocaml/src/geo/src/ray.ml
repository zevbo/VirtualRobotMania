type t = {pt_end: Vec.t; pt_dir: Vec.t}
[@@deriving sexp]

let create pt_end pt_dir = {pt_end;pt_dir}
let to_ll t =
  Line_like.create_w_flip_points
    t.pt_dir (Vec.sub t.pt_dir t.pt_end) [t.pt_end]
let point_angle_form pt angle =
  create pt (Vec.add (Vec.rotate (Vec.create 1. 0.) angle) pt)
let point_slope_form pt slope = point_angle_form pt (Float.atan slope)