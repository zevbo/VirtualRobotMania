open Virtuality2d
open Common
open Geo

let offense_bot () =
  Body.create
    ~pos:(Vec.create (-.Ctf_consts.Bots.x_mag) 0.)
    ~m:Ctf_consts.Bots.mass
    ~angle:Ctf_consts.Bots.start_angle
    ~collision_group:Ctf_consts.Bots.Offense.coll_group
    Ctf_consts.Bots.shape

let gen_updater (offense_bot : State.Offense_bot.t) dt =
  let updater (body : Body.t) _world =
    Set_motors.apply_motor_force
      body
      ~dt
      ~bot_height:Ctf_consts.Bots.height
      ~force_over_input:Ctf_consts.Bots.Offense.force_over_input
      ~air_resistance_c:Ctf_consts.Bots.air_resistance_c
      ~side_fric_k:Ctf_consts.Bots.side_fric_k
      offense_bot.l_input
      offense_bot.r_input
  in
  updater
