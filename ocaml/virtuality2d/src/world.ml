open! Base

module Id : sig
  type t

  include Comparable.S with type t := t

  val of_int : int -> t
  val to_int : t -> int
  val succ : t -> t
  val zero : t
end = struct
  include Int
end

type t = { bodies : world_body Map.M(Id).t }

and updater = Body.t -> t -> Body.t

(* these spec_updaters are all applid at the same time, which means its inputted
   world doesn't update until all the functions have run *)
and world_body =
  { body : Body.t
  ; updater : updater
  }
[@@deriving fields]

let null_updater body _ = body
let create_world_body ?(updater = null_updater) body = { body; updater }
let create () = { bodies = Map.empty (module Id) }

let of_bodies bodies =
  { bodies =
      Map.of_alist_exn
        (module Id)
        (List.mapi bodies ~f:(fun i body ->
             Id.of_int i, { body; updater = null_updater }))
  }

let of_world_bodies bodies =
  { bodies =
      Map.of_alist_exn
        (module Id)
        (List.mapi bodies ~f:(fun i body -> Id.of_int i, body))
  }

let add_world_body t world_body =
  let id =
    match Map.max_elt t.bodies with
    | None -> Id.zero
    | Some (x, _) -> Id.succ x
  in
  { bodies = Map.set t.bodies ~key:id ~data:world_body }

let add_body t ?(updater = null_updater) body =
  add_world_body t { body; updater }

(* TODO: If objects get stuck, we might want a small bounce *)
let collide_bodies bodies =
  let ids = Sequence.of_list (Map.keys bodies) in
  let pairs =
    Sequence.cartesian_product ids ids
    |> Sequence.filter ~f:(fun (x, y) -> Id.( > ) x y)
  in
  Sequence.fold pairs ~init:bodies ~f:(fun bodies (i1, i2) ->
      let wb1 = Map.find_exn bodies i1 in
      let wb2 = Map.find_exn bodies i2 in
      let b1, b2 = Body.collide wb1.body wb2.body in
      let wb1 = { wb1 with body = b1 } in
      let wb2 = { wb2 with body = b2 } in
      bodies |> Map.set ~key:i1 ~data:wb1 |> Map.set ~key:i2 ~data:wb2)

let update_body t world_body =
  { world_body with body = world_body.updater world_body.body t }

let body_lift f world_body = { world_body with body = f world_body.body }

let advance t ~dt =
  let bodies =
    t.bodies
    |> Map.map ~f:(update_body t)
    |> collide_bodies
    |> Map.map ~f:(body_lift Body.apply_restrictions)
    |> Map.map ~f:(body_lift (Body.advance ~dt))
  in
  { bodies }
