open! Geo
open! Base

type t =
  { edges : Edge.t list
  ; bounding_box : Square.t
  }

let intersections t1 t2 =
  let corners1 = Square.get_corners t1.bounding_box in
  if List.exists corners1 ~f:(fun corner ->
         not (Square.contains t2.bounding_box corner))
  then []
  else (
    let intersections =
      List.map (List.cartesian_product t1.edges t2.edges) ~f:(fun (e1, e2) ->
          Line_like.intersection (Line_seg.to_ll e1.ls) (Line_seg.to_ll e2.ls))
    in
    List.filter_opt intersections)
