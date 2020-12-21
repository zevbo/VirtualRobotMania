open Virtuality2d
open Geo
open Base

let _log_s sexp = Async.Log.Global.info_s sexp

let laser (bot : Body.t) =
  let half_length = Vec.create (Ctf_consts.Bots.width /. 2.) 0. in
  let pos = Vec.add bot.pos (Vec.rotate half_length bot.angle) in
  let angle = bot.angle in
  let v = Vec.scale (Vec.unit_vec angle) Ctf_consts.Laser.v in
  let m = 0.01 in
  Body.create
    ~pos
    ~m
    ~v
    ~angle
    ~max_omega:0.
    ~collision_group:Ctf_consts.Laser.coll_group
    ~black_list:Ctf_consts.Laser.black_list
    Ctf_consts.Laser.shape

let gen_updater (state : State.t) =
  let updater id (laser : Body.t) world =
    let offense_bodies =
      World.all_of_coll_group world Ctf_consts.Bots.Offense.coll_group
    in
    let hit_offense_body =
      Option.is_some
        (List.find offense_bodies ~f:(fun (_id, body) ->
             not
               (List.length
                  (Body.intersections ~allow_blacklist:true body laser)
               = 0)))
    in
    if hit_offense_body
    then (
      let new_world = World.remove_body world id in
      assert (Map.length new_world.bodies + 1 = Map.length state.world.bodies);
      state.world <- new_world);
    { laser with
      v = Vec.scale (Vec.to_unit laser.v) Ctf_consts.Laser.v
    ; angle = Vec.angle_of laser.v
    }
  in
  updater
