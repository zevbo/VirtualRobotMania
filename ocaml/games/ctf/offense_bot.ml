open Virtuality2d
open Common
open Geo

type t =
  { mutable has_flag : bool
  ; mutable lives : int
  ; mutable l_input : float
  ; mutable r_input : float
  }
[@@deriving fields]

let create () =
  { has_flag = false
  ; lives = Ctf_consts.Bots.Offense.start_lives
  ; l_input = 0.
  ; r_input = 0.
  }

let gen_updater (offense_bot : t) dt =
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
    pos = Ctf_consts.Bots.Offense.start_pos
  ; v = Vec.origin
  ; angle = Ctf_consts.Bots.start_angle
  }

let offense_bot () =
  let body =
    Body.create
      ~m:Ctf_consts.Bots.mass
      ~collision_group:Ctf_consts.Bots.Offense.coll_group
      Ctf_consts.Bots.shape
  in
  reset body

let remove_live offense_bot (offense_bot_body : Body.t) =
  offense_bot.lives <- offense_bot.lives - 1;
  if offense_bot.lives = 0
  then (
    offense_bot.lives <- Ctf_consts.Bots.Offense.start_lives;
    offense_bot.has_flag <- false;
    reset offense_bot_body)
  else offense_bot_body
