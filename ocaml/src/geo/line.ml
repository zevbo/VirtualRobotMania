open! Vec
open! Line_like

type t = {pt1: Vec.t; pt2: Vec.t}
let create pt1 pt2 = {pt1; pt2}
let to_ll t = Line_like.create_w_points t.pt1 t.pt2 []
let point_angle_form pt angle = create pt (Vec.rotate (Vec.create 1. 0.) angle)
let point_slope_form pt slope = point_angle_form pt (Float.atan slope)