open! Core_kernel
open Virtuality2d
open Geo
open Ctf_consts.Flag

let get_random_pos () =
  let y_mag = Random.float_range min_y max_y in
  let y = y_mag *. if Random.bool () then -1. else 1. in
  let x = Random.float_range min_x max_x in
  Vec.create x y

let flag () =
  Body.create
    ~pos:(get_random_pos ())
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
  let flag_protector = World.get_body_exn state.world state.flag_protector in
  let black_list =
    (if in_use then Set.add else Set.remove)
      flag_protector.black_list
      Ctf_consts.Bots.Defense.coll_group
  in
  let flag_protector = { flag_protector with black_list } in
  World.set_body world state.flag_protector flag_protector

let gen_updater (state : State.t) =
  let updater id (flag : Body.t) world =
    let picked_up_flag =
      not
        (List.is_empty
           (Body.intersections
              ~allow_blacklist:true
              flag
              (State.get_offense_bot_body state)))
    in
    if picked_up_flag then (fst state.offense_bot).has_flag <- true;
    (* this find_exn should eventually be changed probably *)
    let on_ground = snd (Map.find_exn state.images state.flag_protector) in
    let world =
      if (fst state.offense_bot).has_flag && on_ground
      then set_flag_protector_state state world false
      else if (not (fst state.offense_bot).has_flag) && not on_ground
      then set_flag_protector_state state world true
      else world
    in
    let bot = State.get_offense_bot_body state in
    let flag =
      if (fst state.offense_bot).has_flag
      then { flag with pos = bot.pos; angle = bot.angle -. (Float.pi /. 2.) }
      else flag
    in
    World.set_body world id flag
  in
  updater
