open! Core_kernel
open Virtuality2d

let bot_collision (state : State.t) =
  let bot_collisions =
    Body.intersections
      ~allow_blacklist:true
      (State.get_defense_bot_body state)
      (State.get_offense_bot_body state)
  in
  if not (List.is_empty bot_collisions)
  then (
    let offense_bot =
      Offense_bot.remove_live
        state.offense_bot.bot
        ~num_lives:Ctf_consts.Bots.Offense.start_lives
        (State.get_offense_bot_body state)
    in
    state.world <- World.set_body state.world state.offense_bot.id offense_bot)

let _check_wall_enhance (state : State.t) =
  if Float.O.(
       state.last_wall_enhance +. Ctf_consts.Border.enhance_period < state.ts)
  then
    state.world
      <- Border.set_border_black_list state.world Ctf_consts.Border.black_list

let run (state : State.t) ~dt =
  let update_bodies f =
    state.world <- { World.bodies = f state.world.bodies }
  in
  let update_body id f =
    update_bodies (fun bodies ->
        Map.update bodies id ~f:(function
            | None ->
              raise_s [%message "Id unexpectedly missing" (id : World.Id.t)]
            | Some body -> f body))
  in
  update_body state.offense_bot.id (fun body ->
      Offense_bot.update state.offense_bot.bot ~dt body state.ts);
  update_body state.defense_bot.id (fun body ->
      Defense_bot.update state.defense_bot.bot ~dt body);
  (*check_wall_enhance state;*)
  bot_collision state;
  Flag_logic.update state;
  Laser_logic.update state;
  state.world <- World.advance state.world ~dt
