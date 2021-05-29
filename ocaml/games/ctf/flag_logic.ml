open! Core_kernel
open Virtuality2d
open Geo
open Ctf_consts.Flag

module Make (Display : Geo_graph.Display_intf.S) = struct
  module State = State.Make (Display)

  let rec get_random_pos (defense_bot : Body.t) =
    let y = min_y +. Random.float_range 0. (max_y -. min_y) in
    let y = if Random.bool () then y else -.y in
    let x = Random.float_range min_x max_x in
    let pos = Vec.create x y in
    if Float.O.(
         Vec.dist_sq pos defense_bot.pos
         < (Ctf_consts.Flag.no_defense_dist
           +. (Ctf_consts.Bots.width /. 2.)
           +. Ctf_consts.Flag.Protector.initial_defense_passing)
           **. 2.)
    then get_random_pos defense_bot
    else pos

  let flag defense_bot =
    Body.create
      ~pos:(get_random_pos defense_bot)
      ~black_list
      ~collision_group:coll_group
      ~m
      shape

  let flag_protector (flag : Body.t) =
    Body.create
      ~pos:flag.pos
      ~angle:0.
      ~collision_group:Protector.coll_group
      ~black_list:Protector.black_list
      ~m:Protector.m
      Protector.shape

  let update_flag_protector_visibility (state : State.t) to_use =
    state.invisible
      <- (if to_use
         then Set.remove state.invisible state.flag_protector
         else Set.add state.invisible state.flag_protector)

  let set_flag_protector_state (state : State.t) world in_use =
    update_flag_protector_visibility state in_use;
    let flag_protector = World.get_body_exn world state.flag_protector in
    let modify_black_list =
      if in_use then Body.remove_from_black_list else Body.add_to_black_list
    in
    let flag_protector =
      modify_black_list flag_protector Ctf_consts.Bots.Defense.coll_group
    in
    let flag_protector =
      modify_black_list flag_protector Ctf_consts.Laser.coll_group
    in
    let pos = (World.get_body_exn world state.flag).pos in
    let flag_protector = { flag_protector with pos } in
    World.set_body world state.flag_protector flag_protector

  let update (state : State.t) =
    let flag_body = Map.find_exn state.world.bodies state.flag in
    let picked_up_flag =
      not
        (List.is_empty
           (Body.intersections
              ~allow_blacklist:true
              flag_body
              (State.get_offense_bot_body state)))
    in
    if picked_up_flag then Offense_bot.set_has_flag state.offense_bot.bot true;
    (* this find_exn should eventually be changed probably *)
    let bot = State.get_offense_bot_body state in
    let on_ground = not (Set.mem state.invisible state.flag_protector) in
    let flag_body =
      if state.offense_bot.bot.has_flag
      then
        { flag_body with pos = bot.pos; angle = bot.angle -. (Float.pi /. 2.) }
      else if not on_ground
      then flag (State.get_defense_bot_body state)
      else flag_body
    in
    let world = World.set_body state.world state.flag flag_body in
    let world =
      if state.offense_bot.bot.has_flag && on_ground
      then set_flag_protector_state state world false
      else if (not state.offense_bot.bot.has_flag) && not on_ground
      then set_flag_protector_state state world true
      else world
    in
    assert (
      let flag_protector = World.get_body_exn world state.flag_protector in
      (not state.offense_bot.bot.has_flag)
      || Set.exists flag_protector.black_list ~f:(fun group ->
             group = Ctf_consts.Laser.coll_group));
    state.world <- world
end
