open Virtuality2d
open Common
open Geo

let gen_updater (offense_bot : State.Offense_bot.t) dt =
  let body_updater _id (body : Body.t) _world =
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
  World.to_world_updater body_updater

let reset (body : Body.t) =
  { body with
    pos = Vec.create (-.Ctf_consts.Bots.x_mag) 0.
  ; v = Vec.origin
  ; angle = 0.
  }

let offense_bot () =
  let body =
    Body.create
      ~m:Ctf_consts.Bots.mass
      ~angle:Ctf_consts.Bots.start_angle
      ~collision_group:Ctf_consts.Bots.Offense.coll_group
      Ctf_consts.Bots.shape
  in
  reset body

let remove_live (offense_bot_body : Body.t) (offense_bot : State.Offense_bot.t) =
  offense_bot.lives <- offense_bot.lives - 1;
  if offense_bot.lives = 0
  then (
    offense_bot.lives <- Ctf_consts.Bots.Offense.start_lives;
    reset offense_bot_body)
  else offense_bot_body
