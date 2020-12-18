open! Base

module Id : sig
  type t

  include Comparable.S with type t := t

  val to_int : t -> int
  val of_int : int -> t
  val succ : t -> t
  val zero : t
end = struct
  module T = struct
    type t = int [@@deriving sexp, compare]
  end

  include T
  include Comparable.Make (T)

  let succ = Int.succ
  let to_int = Fn.id
  let of_int = Fn.id
  let zero = zero
end

type t =
  { next_id : Id.t
  ; bodies : Body.t Map.M(Id).t
  }

let create () = { bodies = Map.empty (module Id); next_id = Id.zero }
let bodies t = t.bodies

let add_body t body =
  let id = t.next_id in
  let t =
    { bodies = Map.add_exn t.bodies ~key:id ~data:body
    ; next_id = Id.succ t.next_id
    }
  in
  id, t

let remove_body t id = { t with bodies = Map.remove t.bodies id }

(* TODO: If objects get stuck, we might want a small bounce *)
let collide_bodies bodies =
  let ids = Map.keys bodies |> Sequence.of_list in
  let pairs =
    Sequence.cartesian_product ids ids
    |> Sequence.filter ~f:(fun (x, y) -> Id.( > ) x y)
  in
  Sequence.fold pairs ~init:bodies ~f:(fun bodies (id1, id2) ->
      let b1, b2 =
        Body.collide (Map.find_exn bodies id1) (Map.find_exn bodies id2)
      in
      let bodies = Map.set bodies ~key:id1 ~data:b1 in
      let bodies = Map.set bodies ~key:id2 ~data:b2 in
      bodies)

let advance t ~dt =
  { t with
    bodies =
      collide_bodies t.bodies |> Map.map ~f:(fun body -> Body.advance body ~dt)
  }
