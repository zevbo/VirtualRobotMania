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

type t =
  { bodies : Body.t Map.M(Id).t
  ; updaters : (Body.t -> t -> Body.t) Map.M(Id).t
  }

let null_updater body _ = body
let empty = { bodies = Map.empty (module Id); updaters = Map.empty (module Id) }

let of_bodies bodies =
  let bodies =
    Map.of_alist_exn
      (module Id)
      (List.mapi bodies ~f:(fun i body -> Id.of_int i, body))
  in
  let updaters = Map.map bodies ~f:(fun _ -> null_updater) in
  { bodies; updaters }

let of_bodies_and_updaters bodies_and_updaters =
  let both =
    Map.of_alist_exn
      (module Id)
      (List.mapi bodies_and_updaters ~f:(fun i pair -> Id.of_int i, pair))
  in
  { bodies = Map.map both ~f:fst; updaters = Map.map both ~f:snd }

let add_body t ?(updater = null_updater) body =
  let id =
    match Map.max_elt t.bodies with
    | None -> Id.zero
    | Some (x, _) -> Id.succ x
  in
  ( { bodies = Map.set t.bodies ~key:id ~data:body
    ; updaters = Map.set t.updaters ~key:id ~data:updater
    }
  , id )

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

let update t id body =
  match Map.find t.updaters id with
  | None -> body
  | Some f -> f body t

let advance t ~dt =
  let bodies =
    t.bodies
    |> Map.mapi ~f:(fun ~key:id ~data:body -> update t id body)
    |> collide_bodies dt
    |> Map.map ~f:Body.apply_restrictions
    |> Map.map ~f:(Body.advance ~dt)
  in
  { t with bodies }
