open Geo
open! Base

type t =
  { edges : Edge.t list
  ; bounding_box : Rect.t
  }
[@@deriving sexp_of]

let create (edges : Edge.t list) =
  let points =
    List.fold edges ~init:[] ~f:(fun points edge ->
        Line_like.get_p1 edge.ls :: Line_like.get_p2 edge.ls :: points)
  in
  let center_and_span getter =
    let vals = List.map points ~f:getter in
    let min_val = List.reduce_exn vals ~f:Float.min in
    let max_val = List.reduce_exn vals ~f:Float.max in
    (min_val +. max_val) /. 2., max_val -. min_val
  in
  let x_center, x_span = center_and_span Vec.x in
  let y_center, y_span = center_and_span Vec.y in
  let bounding_box = Rect.create x_span y_span (Vec.create x_center y_center) in
  { edges; bounding_box }

exception Bad_shape_creation of string

let create_closed (points : Vec.t list) material =
  let make_edge p1 p2 = Edge.create (Line_like.segment p1 p2) material in
  let rec create_edges points starting_point =
    match points with
    | [] -> raise (Failure "empty points")
    | [ pt ] -> [ make_edge starting_point pt ]
    | pt1 :: pt2 :: tl ->
      make_edge pt1 pt2 :: create_edges (pt2 :: tl) starting_point
  in
  match points with
  | [] | [ _ ] | [ _; _ ] ->
    raise
      (Bad_shape_creation
         ("Create_closed constructor given fewer than 3 points. Points: "
         ^ String.t_of_sexp [%sexp (points : Vec.t list)]))
  | first_point :: _tl -> create (create_edges points first_point)

let create_rect width height ?(com = Vec.origin) material =
  let x = width /. 2. in
  let y = height /. 2. in
  let tl = Vec.create (-.x) y in
  let tr = Vec.create x y in
  let br = Vec.create x (-.y) in
  let bl = Vec.create (-.x) (-.y) in
  let points = List.map [ tl; tr; br; bl ] ~f:(fun pt -> Vec.sub pt com) in
  create_closed points material
