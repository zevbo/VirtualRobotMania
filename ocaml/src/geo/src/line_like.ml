open! Base

type t =
  { base : Vec.t
  ; offset : Vec.t
  ; flips : float list [@sexp.list]
  }
[@@deriving sexp]

module type Epsilon_dependent = sig
  val on_line : t -> Vec.t -> bool
  val flip_points_of : t -> Vec.t list
  val create_w_flip_points : Vec.t -> Vec.t -> Vec.t list -> t
  val param_of : t -> Vec.t -> float option
  val are_parallel : t -> t -> bool
  val intersection : t -> t -> Vec.t option
end

module type Epsilon = sig
  val epsilon : float
end

let create base offset flips = { base; offset; flips }

(* param_of_proj_point returns a float c, such that base + c * offset = to
 the given point projected on to the line. *)
let param_of_proj_point t pt =
  Vec.dot (Vec.sub pt t.base) t.offset /. Vec.mag_sq t.offset

let param_to_point t param = Vec.add t.base (Vec.scale t.offset param)
let flips_before t param = List.count t.flips ~f:(fun n -> Float.(n < param))
let start_on t = flips_before t 0. % 2 = 0
let is_param_on t param = Bool.equal (flips_before t param % 2 = 0) (start_on t)

module With_epsilon (Epsilon : Epsilon) = struct
  open Epsilon

  let on_line t pt =
    let param = param_of_proj_point t pt in
    let expected_pt = param_to_point t param in
    let is_t_on = is_param_on t param in
    is_t_on && Vec.equals pt expected_pt ~epsilon

  let param_of t pt =
    if on_line t pt then Some (param_of_proj_point t pt) else None

  exception Bad_line_like_parameter of string

  let create_w_flip_points base offset flip_points =
    let ll_contianer = { base; offset; flips = [] } in
    let param_of_flip flip_pt =
      match param_of ll_contianer flip_pt with
      | Some t -> t
      | None ->
        raise
          (Bad_line_like_parameter
             "attempted to initialize line like with flip_pt not on line")
    in
    let flips = List.map flip_points ~f:param_of_flip in
    { base; offset; flips }

  let flip_points_of t = List.map t.flips ~f:(param_to_point t)
  let slope_of t = t.offset.y /. t.offset.x
  let angle_of t = Float.atan (slope_of t)

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
      let u = t1.offset in
      let v = t2.offset in
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
