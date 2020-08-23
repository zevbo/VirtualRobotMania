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

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  ; edge_1 : Edge.t
  ; edge_2 : Edge.t
  }
[@@deriving sexp_of]

(* To do: make sure to shift line_likes *)
let intersections t1 t2 =
  let corners1 = Rect.get_corners t1.bounding_box in
  if List.exists corners1 ~f:(fun corner ->
         not (Rect.contains t2.bounding_box corner))
  then []
  else (
    let intersecting_pairs =
      (* create and do_intersect in Line_like and use here *)
      List.map (List.cartesian_product t1.edges t2.edges) ~f:(fun (e1, e2) ->
          match Line_like.intersection e1.ls e2.ls with
          | Some pt ->
            Some
              { pt
              ; energy_ret = Material.energy_ret_of e1.material e2.material
              ; edge_1 = e1
              ; edge_2 = e2
              }
          | None -> None)
    in
    List.filter_opt intersecting_pairs)

let closest_dist_to_corner inter (edge : Edge.t) =
  let flip_points = Line_like.flip_points_of edge.ls in
  let dists =
    List.map flip_points ~f:(fun flip_point -> Vec.dist inter.pt flip_point)
  in
  Float.min (List.nth_exn dists 0) (List.nth_exn dists 1)
