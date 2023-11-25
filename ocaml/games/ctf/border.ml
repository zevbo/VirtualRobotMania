open Common
open Virtuality2d
open Core

let border =
  Border.generate_border
    ~energy_ret:Ctf_consts.Border.energy_ret
    ~collision_group:Ctf_consts.Border.coll_group
    ~black_list:Ctf_consts.Border.black_list
    Ctf_consts.frame_width
    Ctf_consts.frame_height

let border_of_world (world : World.t) =
  List.filter (Map.to_alist world.bodies) ~f:(fun (_id, body) ->
    body.collision_group = Ctf_consts.Border.coll_group)

let set_body_black_list black_list (world : World.t) id =
  let body = World.get_body_exn world id in
  let body = Body.set_black_list body black_list in
  World.set_body world id body

let set_border_black_list (world : World.t) black_list =
  let borders = border_of_world world in
  let ids = List.map borders ~f:fst in
  List.fold ids ~init:world ~f:(set_body_black_list black_list)
