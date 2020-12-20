open Virtuality2d
open Common
open Geo

let gen_updater (defense_bot : State.Defense_bot.t) dt =
  let updater (body : Body.t) _world =
    Set_motors.apply_motor_force
      body
      ~dt
      ~bot_height:Ctf_consts.Bots.height
      ~force_over_input:Ctf_consts.Bots.Defense.force_over_input
      ~air_resistance_c:Ctf_consts.Bots.air_resistance_c
      ~side_fric_k:Ctf_consts.Bots.side_fric_k
      defense_bot.l_input
      defense_bot.r_input
  in
  updater

let defense_bot () =
  Body.create
    ~pos:(Vec.create Ctf_consts.Bots.x_mag 0.)
    ~m:Ctf_consts.Bots.mass
    ~angle:(Float.pi -. Ctf_consts.Bots.start_angle)
    ~collision_group:Ctf_consts.Bots.Defense.coll_group
    ~black_list:Ctf_consts.Bots.Defense.black_list
    Ctf_consts.Bots.shape
