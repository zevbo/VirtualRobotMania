open Virtuality2d
open Geo
open Core_kernel

module Make (Display : Geo_graph.Display_intf.S) = struct
  module State = State.Make (Display)

  let laser ~(bot : Body.t) =
    let half_length = Vec.create (Ctf_consts.Bots.width /. 2.) 0. in
    let pos = Vec.add bot.pos (Vec.rotate half_length bot.angle) in
    let angle = bot.angle in
    let v = Vec.origin in
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

  let power_of ts (laser : State.Laser.t) =
    1
    + Int.of_float ((ts -. laser.loaded_ts) /. Ctf_consts.Laser.next_level_time)

  let shoot_laser (state : State.t) (laser_id : World.Id.t) =
    let laser = World.get_body_exn state.world laser_id in
    let v =
      Vec.scale
        (Vec.unit_vec (State.get_defense_bot_body state).angle)
        Ctf_consts.Laser.v
    in
    let world = World.set_body state.world laser_id { laser with v } in
    (Map.find_exn state.lasers laser_id).loaded <- false;
    state.defense_bot.bot.loaded_laser <- None;
    state.world <- world

  let out_of_frame (laser : Body.t) =
    Float.O.(
      Float.abs laser.pos.x -. (Ctf_consts.Laser.length /. 2.)
      > Ctf_consts.frame_width /. 2.
      || Float.abs laser.pos.y -. (Ctf_consts.Laser.length /. 2.)
         > Ctf_consts.frame_height /. 2.)

  let update_moving (state : State.t) id =
    let laser = Map.find_exn state.world.bodies id in
    if out_of_frame laser
    then state.world <- World.remove_body state.world id
    else (
      let offense_bodies =
        World.all_of_coll_group state.world Ctf_consts.Bots.Offense.coll_group
      in
      assert (List.length offense_bodies = 1);
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
            ~num_lives:(Map.find_exn state.lasers id).power
            state.offense_bot.bot
            (State.get_offense_bot_body state)
            state.ts
        in
        let world =
          { World.bodies =
              Map.set world.bodies ~key:state.offense_bot.id ~data:offense_bot
          }
        in
        state.world <- world)
      else (
        let new_laser =
          { laser with
            v = Vec.scale (Vec.to_unit laser.v) Ctf_consts.Laser.v
          ; angle = Vec.angle_of laser.v
          }
        in
        let new_bodies = Map.set state.world.bodies ~key:id ~data:new_laser in
        state.world <- { World.bodies = new_bodies }))

  let restock_laser (state : State.t) id =
    state.defense_bot.bot.loaded_laser <- None;
    state.images <- Map.remove state.images id;
    state.lasers <- Map.remove state.lasers id;
    state.world <- World.remove_body state.world id

  let update_loaded (state : State.t) id =
    let laser = World.get_body_exn state.world id in
    let bot = State.get_defense_bot_body state in
    let half_length = Vec.create (Ctf_consts.Bots.width /. 2.) 0. in
    let pos =
      Vec.add bot.pos (Vec.scale (Vec.rotate half_length bot.angle) 0.5)
    in
    let laser = { laser with angle = bot.angle; pos } in
    let t = Map.find_exn state.lasers id in
    t.power <- power_of state.ts t;
    if t.power > List.length Ctf_consts.Laser.colors
    then restock_laser state id
    else (
      let image = List.nth_exn state.laser (t.power - 1) in
      state.images <- Map.set state.images ~key:id ~data:image;
      state.world <- World.set_body state.world id laser)

  let update_one (state : State.t) id =
    (if (Map.find_exn state.lasers id).loaded
    then update_loaded
    else update_moving)
      state
      id

  let update (state : State.t) =
    List.iter (Map.to_alist state.lasers) ~f:(fun (id, _laser_state) ->
        update_one state id);
    state.lasers <- Map.filter_keys state.lasers ~f:(Map.mem state.world.bodies)
end
