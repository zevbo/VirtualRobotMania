open! Base

module Id : sig
  type t [@@deriving sexp]

  include Comparable.S with type t := t

  val of_int : int -> t
  val to_int : t -> int
  val succ : t -> t
  val zero : t
end = struct
  include Int
end

type t = { bodies : Body.t Map.M(Id).t } [@@deriving sexp_of]

let empty = { bodies = Map.empty (module Id) }

exception Nonexistent_world_id of Id.t * Id.t list

let get_body_exn t id =
  match Map.find t.bodies id with
  | Some body -> body
  | None -> raise (Nonexistent_world_id (id, Map.keys t.bodies))

let of_bodies bodies =
  let bodies =
    Map.of_alist_exn
      (module Id)
      (List.mapi bodies ~f:(fun i body -> Id.of_int i, body))
  in
  { bodies }

let add_body t body =
  let id =
    match Map.max_elt t.bodies with
    | None -> Id.zero
    | Some (x, _) -> Id.succ x
  in
  { bodies = Map.set t.bodies ~key:id ~data:body }, id

let set_body t id body = { bodies = Map.set t.bodies ~key:id ~data:body }
let remove_body t id = { bodies = Map.remove t.bodies id }

(* TODO: If objects get stuck, we might want a small bounce *)
let collide_bodies dt bodies =
  let ids = Sequence.of_list (Map.keys bodies) in
  let pairs =
    Sequence.cartesian_product ids ids
    |> Sequence.filter ~f:(fun (x, y) -> Id.( > ) x y)
  in
  Sequence.fold pairs ~init:bodies ~f:(fun bodies (i1, i2) ->
      let b1 = Map.find_exn bodies i1 in
      let b2 = Map.find_exn bodies i2 in
      let b1, b2 = Body.collide dt b1 b2 in
      bodies |> Map.set ~key:i1 ~data:b1 |> Map.set ~key:i2 ~data:b2)

let advance t ~dt =
  let bodies =
    t.bodies
    |> collide_bodies dt
    |> Map.map ~f:Body.apply_restrictions
    |> Map.map ~f:(Body.advance ~dt)
  in
  { bodies }

let all_of_coll_group t coll_group =
  List.filter (Map.to_alist t.bodies) ~f:(fun (_id, body) ->
      body.collision_group = coll_group)
