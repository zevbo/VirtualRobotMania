open Virtuality2d
open Common

type t =
  { mutable last_fire_ts : float
  ; mutable l_input : float
  ; mutable r_input : float
  }
[@@deriving fields]

let create () = { last_fire_ts = 0.; l_input = 0.; r_input = 0. }

let defense_bot () =
  Body.create
    ~pos:Ctf_consts.Bots.Defense.start_pos
    ~m:Ctf_consts.Bots.mass
    ~angle:(Float.pi -. Ctf_consts.Bots.start_angle)
    ~collision_group:Ctf_consts.Bots.Defense.coll_group
    ~black_list:Ctf_consts.Bots.Defense.black_list
    Ctf_consts.Bots.shape

let gen_updater (defense_bot : t) dt =
  let body_updater _id (body : Body.t) _world =
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
  World.to_world_updater body_updater
