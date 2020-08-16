open! Geo
open! Base

type t =
  { edges : Edge.t list
  ; bounding_box : Square.t
  }

type intersection =
  { pt : Vec.t
  ; energy_ret : float
  }

(* To do: make sure to shift line_likes *)
let intersections t1 t2 =
  let corners1 = Square.get_corners t1.bounding_box in
  if List.exists corners1 ~f:(fun corner ->
         not (Square.contains t2.bounding_box corner))
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
              }
          | None -> None)
    in
    List.filter_opt intersecting_pairs)
