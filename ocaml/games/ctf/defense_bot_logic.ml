open Virtuality2d
open Common

let gen_updater _state (defense_bot : State.Defense_bot.t) dt =
  let updater (body : Body.t) _world =
    Set_motors.apply_motor_force
      body
      ~dt
      ~bot_height:Bodies.bot_height
      ~force_over_input:Ctf_consts.defense_force_over_input
      ~air_resistance_c:Ctf_consts.air_resistance_c
      ~side_fric_k:Ctf_consts.side_fric_k
      defense_bot.l_input
      defense_bot.r_input
  in
  updater
