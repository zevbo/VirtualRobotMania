open Geo
open! Base

(* A shape implies distribution of mass, but not its scale *)
type t =
  { edges : Edge.t list
  ; bounding_box : Rect.t
  ; average_r : float
  ; inertia_over_mass : float
  }
[@@deriving sexp_of]

let create ~(edges : Edge.t list) ~average_r ~inertia_over_mass =
  assert (not (Float.is_nan average_r));
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
  { edges; bounding_box; average_r; inertia_over_mass }

exception Bad_shape_creation of string

let create_closed ~(points : Vec.t list) ~material ~average_r ~inertia_over_mass
  =
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
  | first_point :: _tl ->
    let edges = create_edges points first_point in
    create ~edges ~average_r ~inertia_over_mass

let get_corners ?(com = Vec.origin) width height =
  let x = width /. 2. in
  let y = height /. 2. in
  let tl = Vec.create (-.x) y in
  let tr = Vec.create x y in
  let br = Vec.create x (-.y) in
  let bl = Vec.create (-.x) (-.y) in
  List.map [ tl; tr; br; bl ] ~f:(fun pt -> Vec.sub pt com)

let create_rect
  ?(com = Vec.origin)
  width
  height
  ~material
  ~average_r
  ~inertia_over_mass
  =
  let points = get_corners width height ~com in
  create_closed ~points ~material ~average_r ~inertia_over_mass

let create_standard_rect ?(com = Vec.origin) width height ~material =
  let get_mass_percentage (corner : Vec.t) =
    Float.abs (corner.x *. corner.y /. (width *. height))
  in
  let inertia_over_mass_of_section (corner : Vec.t) =
    get_mass_percentage corner *. ((corner.x **. 2.) +. (corner.y **. 2.)) /. 3.
  in
  let average_r_of_section (corner : Vec.t) =
    if Float.(corner.x = 0. && corner.y = 0.)
    then 0.
    else (
      let max_angle = Float.abs (Float.atan2 corner.y corner.x) in
      let max_angle =
        if Float.(Float.cos max_angle = 0.)
        then Float.abs (Float.atan2 corner.x corner.y)
        else max_angle
      in
      let sec = Float.abs (1. /. Float.cos max_angle) in
      let tan = Float.abs (Float.tan max_angle) in
      let integral = (sec *. tan) +. Float.log (Float.abs (sec +. tan)) in
      let r =
        Float.abs
          ((corner.x **. 2.)
          *. get_mass_percentage corner
          *. integral
          /. (3. *. corner.y))
      in
      assert (not (Float.is_nan r));
      r)
  in
  let corners = get_corners ~com width height in
  let inertia_over_mass =
    List.fold
      (List.map corners ~f:inertia_over_mass_of_section)
      ~init:0.
      ~f:( +. )
  in
  let average_r =
    List.fold (List.map corners ~f:average_r_of_section) ~init:0. ~f:( +. )
  in
  create_rect width height ~com ~material ~average_r ~inertia_over_mass
