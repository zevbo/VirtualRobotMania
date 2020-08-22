open! Base

type t =
  { x : float
  ; y : float
  }
[@@derving fields]

(* We make s-expressions look like simple pairs, eg., (3 4), 
   rather than a record, e.g., ((x 3) (y 4)). *)
include Sexpable.Of_sexpable
          (struct
            type t = Float.Terse.t * Float.Terse.t [@@deriving sexp]
          end)
          (struct
            type nonrec t = t

            let to_sexpable { x; y } = x, y
            let of_sexpable (x, y) = { x; y }
          end)

let normal_angle_range = 2. *. Float.pi
let center_angle = 0.
let min_angle = center_angle -. (normal_angle_range /. 2.)
let max_angle = min_angle +. normal_angle_range

let normalize_angle angle =
  let float_modulo n1 n2 =
    let rem = Caml.Float.rem n1 n2 in
    if Float.(rem < 0.) then rem +. n2 else rem
  in
  float_modulo (angle -. min_angle) normal_angle_range +. min_angle

let create x y = { x; y }
let origin = create 0. 0.
let mag_sq t = (t.x *. t.x) +. (t.y *. t.y)
let mag t = Float.sqrt (mag_sq t)
let scale t c = { x = t.x *. c; y = t.y *. c }
let add t1 t2 = { x = t1.x +. t2.x; y = t1.y +. t2.y }
let sub t1 t2 = add t1 (scale t2 (-1.))
let to_unit t = scale t (1. /. mag t)

let collinear ~epsilon t1 t2 t3 =
  let open Float in
  let deviation =
    abs
      (((t2.y -. t1.y) *. (t3.x -. t2.x)) -. ((t2.x -. t1.x) *. (t3.y -. t2.y)))
  in
  deviation < epsilon

let dist_sq t1 t2 = mag_sq (sub t1 t2)
let dist t1 t2 = Float.sqrt (dist_sq t1 t2)

let equals ~epsilon t1 t2 =
  Float.O.(abs (t1.x - t2.x) < epsilon && abs (t1.y - t2.y) < epsilon)

let rotate pt angle =
  create
    ((pt.x *. Float.cos angle) -. (pt.y *. Float.sin angle))
    ((pt.y *. Float.cos angle) +. (pt.x *. Float.sin angle))

let mid_point pt1 pt2 = scale (add pt1 pt2) 0.5

let avg_point pts =
  scale
    (List.fold_left pts ~init:origin ~f:add)
    (1. /. Float.of_int (List.length pts))

let dot t1 t2 = Float.O.((t1.x * t2.x) + (t1.y * t2.y))
let angle_of t = Float.atan2 t.y t.x
let angle_between t1 t2 = angle_of (sub t2 t1)
let angle_with_origin t1 t2 = normalize_angle (angle_of t1 -. angle_of t2)
let unit_vec angle = rotate (create 1. 0.) angle
