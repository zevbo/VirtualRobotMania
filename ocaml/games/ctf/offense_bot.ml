open Virtuality2d
open Common
open Core
open Geo

type t =
  { mutable has_flag : bool
  ; mutable num_flags : int
  ; mutable last_boost : float
  ; mutable lives : int
  ; mutable l_input : float
  ; mutable r_input : float
  }
[@@deriving fields]

let create () =
  { has_flag = false
  ; num_flags = 0
  ; lives = Ctf_consts.Bots.Offense.start_lives
  ; last_boost = -.Ctf_consts.Bots.Offense.boost_cooldown
  ; l_input = 0.
  ; r_input = 0.
  }

let update t ~dt (body : Body.t) ts =
  let body =
    if Float.O.(t.last_boost = ts)
    then
      { body with v = Vec.scale body.v Ctf_consts.Bots.Offense.boost_v_scale }
    else body
  in
  if t.has_flag
     && Float.O.(
          body.pos.x < Ctf_consts.End_line.x +. (Ctf_consts.End_line.w /. 2.))
  then (
    t.has_flag <- false;
    t.num_flags <- t.num_flags + 1);
  Set_motors.apply_motor_force
    body
    ~dt
    ~bot_height:Ctf_consts.Bots.height
    ~force_over_input:Ctf_consts.Bots.Offense.force_over_input
    ~air_resistance_c:Ctf_consts.Bots.air_resistance_c
    ~side_fric_k:Ctf_consts.Bots.side_fric_k
    t.l_input
    t.r_input

let reset (body : Body.t) =
  { body with
    pos = Ctf_consts.Bots.Offense.start_pos
  ; v = Vec.origin
  ; angle = Ctf_consts.Bots.start_angle
  }

let body =
  reset
    (Body.create
       ~m:Ctf_consts.Bots.mass
       ~collision_group:Ctf_consts.Bots.Offense.coll_group
       Ctf_consts.Bots.shape)

let remove_live t ?(num_lives = 1) (offense_bot_body : Body.t) =
  t.lives <- t.lives - num_lives;
  if t.lives <= 0
  then (
    t.lives <- Ctf_consts.Bots.Offense.start_lives;
    t.has_flag <- false;
    reset offense_bot_body)
  else offense_bot_body
