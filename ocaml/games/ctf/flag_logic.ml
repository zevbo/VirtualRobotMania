open! Core_kernel
open Virtuality2d
open Geo
open Ctf_consts.Flag

let rec get_random_pos (defense_bot : Body.t) =
  let y = Random.float_range (-.max_y) max_y in
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
  state.images
    <- Map.update state.images state.flag_protector ~f:(fun data ->
           let img, _ = Option.value_exn data in
           img, to_use)

let set_flag_protector_state (state : State.t) world in_use =
  update_flag_protector_visibility state in_use;
  let flag_protector = World.get_body_exn world state.flag_protector in
  let modify_set = if in_use then Set.remove else Set.add in
  let black_list =
    modify_set flag_protector.black_list Ctf_consts.Bots.Defense.coll_group
  in
  let black_list = modify_set black_list Ctf_consts.Laser.coll_group in
  let pos = (World.get_body_exn world state.flag).pos in
  let flag_protector = { flag_protector with black_list; pos } in
  World.set_body world state.flag_protector flag_protector

let gen_updater (state : State.t) =
  let updater id (flag_body : Body.t) world =
    let picked_up_flag =
      not
        (List.is_empty
           (Body.intersections
              ~allow_blacklist:true
              flag_body
              (State.get_offense_bot_body state)))
    in
    if picked_up_flag then Offense_bot.set_has_flag (fst state.offense_bot) true;
    (* this find_exn should eventually be changed probably *)
    let bot = State.get_offense_bot_body state in
    let on_ground = snd (Map.find_exn state.images state.flag_protector) in
    let flag_body =
      if (fst state.offense_bot).has_flag
      then
        { flag_body with pos = bot.pos; angle = bot.angle -. (Float.pi /. 2.) }
      else if not on_ground
      then flag (State.get_defense_bot_body state)
      else flag_body
    in
    let world = World.set_body world id flag_body in
    let world =
      if (fst state.offense_bot).has_flag && on_ground
      then set_flag_protector_state state world false
      else if (not (fst state.offense_bot).has_flag) && not on_ground
      then set_flag_protector_state state world true
      else world
    in
    let flag_protector = World.get_body_exn world state.flag_protector in
    assert (
      (not (fst state.offense_bot).has_flag)
      || Set.exists flag_protector.black_list ~f:(fun group ->
             group = Ctf_consts.Laser.coll_group));
    world
  in
  updater
