open! Core_kernel
open Virtuality2d

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
      Offense_bot.update state.offense_bot.bot ~dt body);
  update_body state.defense_bot.id (fun body ->
      Defense_bot.update state.defense_bot.bot ~dt body);
  Flag_logic.update state;
  Laser_logic.update state;
  state.world <- World.advance state.world ~dt;
  state.ts <- state.ts +. dt
