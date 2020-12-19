open! Base

type t = { bodies : world_body list }

and updater = Body.t -> t -> Body.t

(* these spec_updaters are all applid at the same time, which means its inputted
   world doesn't update until all the functions have run *)
and world_body =
  { body : Body.t
  ; updaters : updater list
  }
[@@deriving fields]

let create_world_body body updaters = { body; updaters }
let create () = { bodies = [] }
let of_world_bodies world_bodies = { bodies = world_bodies }

let of_bodies bodies =
  of_world_bodies (List.map bodies ~f:(fun body -> { body; updaters = [] }))

let add_world_body t world_body = { bodies = world_body :: t.bodies }

let add_body t ?(updaters = []) body =
  { bodies = { body; updaters } :: t.bodies }

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

let apply_updaters t world_body =
  let apply_updater body updater = updater body t in
  { world_body with
    body = List.fold world_body.updaters ~init:world_body.body ~f:apply_updater
  }

let advance t dt =
  let spec_updated = List.map t.bodies ~f:(apply_updaters t) in
  let collided = collide_bodies (List.map spec_updated ~f:body) in
  let restricted = List.map ~f:Body.apply_restrictions collided in
  let advanced = List.map restricted ~f:(fun body -> Body.advance body ~dt) in
  let final_world_bodies =
    List.map2 advanced (List.map t.bodies ~f:updaters) ~f:create_world_body
  in
  match final_world_bodies with
  | Ok final_world_bodies -> { bodies = final_world_bodies }
  | Unequal_lengths ->
    raise
      (Failure
         "somehow in world.advance, the vodies and worlds have different \
          lengths on 52")
