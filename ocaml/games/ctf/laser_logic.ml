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
    if Float.O.(
         Float.abs laser.pos.x -. (Ctf_consts.Laser.length /. 2.)
         > Ctf_consts.frame_width /. 2.
         || Float.abs laser.pos.y -. (Ctf_consts.Laser.length /. 2.)
            > Ctf_consts.frame_height /. 2.)
    then World.remove_body world id
    else (
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
        let world = World.remove_body world id in
        let offense_bot =
          Offense_bot_logic.remove_live
            (State.get_offense_bot_body state)
            (fst state.offense_bot)
        in
        let world =
          { world with
            bodies =
              Map.set
                world.bodies
                ~key:(snd state.offense_bot)
                ~data:offense_bot
          }
        in
        world)
      else (
        let new_laser =
          { laser with
            v = Vec.scale (Vec.to_unit laser.v) Ctf_consts.Laser.v
          ; angle = Vec.angle_of laser.v
          }
        in
        let new_bodies = Map.set world.bodies ~key:id ~data:new_laser in
        { world with bodies = new_bodies }))
  in
  updater
