type t =
  { pt1 : Vec.t
  ; pt2 : Vec.t
  }
[@@deriving sexp]

let create pt1 pt2 = { pt1; pt2 }

let to_ll t =
  Line_like.create_w_flip_points
    (Vec.mid_point t.pt1 t.pt2)
    (Vec.sub t.pt1 t.pt2)
    [ t.pt1; t.pt2 ]
