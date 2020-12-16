open! Base

type t = { bodies : Body.t list }

let create () = { bodies = [] }
let of_bodies bodies = { bodies }
let add_body t body = { bodies = body :: t.bodies }

(* TODO: If objects get stuck, we might want a small bounce *)
let rec collide_bodies bodies =
  match bodies with
  | [] -> []
  | first_body :: tl ->
    (* I'm confused about this... *)
    let new_first_body, new_tl =
      List.fold_map tl ~init:first_body ~f:Body.collide
    in
    new_first_body :: collide_bodies new_tl

let advance t dt =
  let collided = collide_bodies t.bodies in
  let restricted = List.map ~f:Body.apply_restrictions collided in
  { bodies = List.map ~f:(fun body -> Body.advance body dt) restricted }
