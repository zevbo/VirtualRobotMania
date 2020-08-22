open! Base

type line = Line [@@deriving sexp]
type segment = Segment [@@deriving sexp]
type ray = Ray [@@deriving sexp]

type 'a t =
  { base : Vec.t
  ; dir_vec : Vec.t
  ; flips : float list [@sexp.list]
  }
[@@deriving sexp_of]

module type Epsilon_dependent = sig
  val epsilon : float
  val on_line : _ t -> Vec.t -> bool
  val create_w_flip_points : Vec.t -> Vec.t -> Vec.t list -> 'a t
  val param_of : _ t -> Vec.t -> float option
  val are_parallel : _ t -> _ t -> bool
  val intersection : _ t -> _ t -> Vec.t option
end

module type Epsilon = sig
  val epsilon : float
end

(** param_of_proj_point returns a float c, such that base + c * dir_vec = to
    the given point projected on to the line. *)
let param_of_proj_point t pt =
  Vec.dot (Vec.sub pt t.base) t.dir_vec /. Vec.mag_sq t.dir_vec

let param_to_point t param = Vec.add t.base (Vec.scale t.dir_vec param)
let flips_before t param = List.count t.flips ~f:(fun n -> Float.(n < param))
let start_on t = flips_before t 0. % 2 = 0
let is_param_on t param = Bool.equal (flips_before t param % 2 = 0) (start_on t)
let slope_of t = t.dir_vec.y /. t.dir_vec.x
let angle_of t = Float.atan (slope_of t)
let flip_points_of t = List.map t.flips ~f:(param_to_point t)

module With_epsilon (Epsilon : Epsilon) = struct
  open Epsilon

  let epsilon = epsilon

  let on_line t pt =
    let param = param_of_proj_point t pt in
    let expected_pt = param_to_point t param in
    let is_t_on = is_param_on t param in
    is_t_on && Vec.equals pt expected_pt ~epsilon

  let param_of t pt =
    if on_line t pt then Some (param_of_proj_point t pt) else None

  exception Bad_line_like_parameter of string

  let create_w_flip_points base dir_vec flip_points =
    let ll_contianer = { base; dir_vec; flips = [] } in
    let param_of_flip flip_pt =
      match param_of ll_contianer flip_pt with
      | Some t -> t
      | None ->
        raise
          (Bad_line_like_parameter
             "attempted to initialize line like with flip_pt not on line")
    in
    let flips = List.map flip_points ~f:param_of_flip in
    { base; dir_vec; flips }

  let are_parallel t1 t2 =
    General.imp_equals (angle_of t1) (angle_of t2) ~epsilon

  let intersection_as_lines t1 t2 =
    (* If they're not parallel, the underlying lines must have an
       intersection, even if it's not on the segments in question *)
    let open Float.O in
    if are_parallel t1 t2
    then None
    else (
      (* Algorithm: http://geomalgorithms.com/a05-_intersect-1.html *)
      let u = t1.dir_vec in
      let v = t2.dir_vec in
      let w = Vec.sub t1.base t2.base in
      let s = ((v.y * w.x) - (v.x * w.y)) / ((v.x * u.y) - (v.y * u.x)) in
      let intersection = Vec.add t1.base (Vec.scale u s) in
      Some intersection)

  let intersection t1 t2 =
    match intersection_as_lines t1 t2 with
    | None -> None
    | Some x -> if on_line t1 x && on_line t2 x then Some x else None
end

include With_epsilon (struct
  let epsilon = 0.00001
end)

let line p1 p2 = create_w_flip_points p1 (Vec.sub p2 p2) []

let line_of_point_angle p angle =
  line p (Vec.add (Vec.rotate (Vec.create 1. 0.) angle) p)

let line_of_point_slope p slope = line_of_point_angle p (Float.atan slope)
let ray p1 p2 = create_w_flip_points p2 (Vec.sub p2 p1) [ p1 ]

let ray_of_point_angle p angle =
  ray p (Vec.add (Vec.rotate (Vec.create 1. 0.) angle) p)

let ray_of_point_slope p slope = ray_of_point_angle p (Float.atan slope)

let segment p1 p2 =
  create_w_flip_points (Vec.mid_point p1 p2) (Vec.sub p1 p2) [ p1; p2 ]

let angle_of t = Vec.angle_of t.base
