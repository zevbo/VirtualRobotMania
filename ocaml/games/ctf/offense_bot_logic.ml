open Virtuality2d
open Common

let gen_updater _state (offense_bot : State.Offense_bot.t) dt =
  let updater (body : Body.t) _world =
    Set_motors.apply_motor_force
      body
      ~dt
      ~bot_height:Bodies.bot_height
      ~force_over_input:Ctf_consts.offense_force_over_input
      ~air_resistance_c:Ctf_consts.air_resistance_c
      ~side_fric_k:Ctf_consts.side_fric_k
      offense_bot.l_input
      offense_bot.r_input
  in
  updater
