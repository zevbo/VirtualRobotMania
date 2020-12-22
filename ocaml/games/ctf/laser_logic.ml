open Virtuality2d
open Geo
open Base

let _log_s sexp = Async.Log.Global.info_s sexp

let laser ~(bot : Body.t) =
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

let update_one (state : State.t) id =
  let laser = Map.find_exn state.world.bodies id in
  if Float.O.(
       Float.abs laser.pos.x -. (Ctf_consts.Laser.length /. 2.)
       > Ctf_consts.frame_width /. 2.
       || Float.abs laser.pos.y -. (Ctf_consts.Laser.length /. 2.)
          > Ctf_consts.frame_height /. 2.)
  then World.remove_body state.world id
  else (
    let offense_bodies =
      World.all_of_coll_group state.world Ctf_consts.Bots.Offense.coll_group
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
      let world = World.remove_body state.world id in
      let offense_bot =
        Offense_bot.remove_live
          state.offense_bot.bot
          (State.get_offense_bot_body state)
          state.ts
      in
      let world =
        { World.bodies =
            Map.set world.bodies ~key:state.offense_bot.id ~data:offense_bot
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
      let new_bodies = Map.set state.world.bodies ~key:id ~data:new_laser in
      { World.bodies = new_bodies }))

let update (state : State.t) =
  Set.iter state.lasers ~f:(fun id -> state.world <- update_one state id);
  state.lasers
    <- Set.inter
         state.lasers
         (Set.of_list (module World.Id) (Map.keys state.world.bodies))
