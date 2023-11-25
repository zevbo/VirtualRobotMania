open Virtuality2d
open Common
open Core
open Geo

type t =
  { mutable has_flag : bool
  ; mutable num_flags : int
  ; mutable last_boost : float
  ; mutable last_shield : float
  ; mutable lives : int
  ; mutable l_input : float
  ; mutable r_input : float
  ; mutable last_kill : float
  ; mutable last_flag_return : float
  ; mutable times_killed : int
  }
[@@deriving fields]

let create () =
  { has_flag = false
  ; num_flags = 0
  ; lives = Ctf_consts.Bots.Offense.start_lives
  ; last_boost = -.Ctf_consts.Bots.Offense.boost_cooldown
  ; last_shield = -.Ctf_consts.Bots.Offense.Shield.time
  ; l_input = 0.
  ; r_input = 0.
  ; last_kill = -1.
  ; last_flag_return = -1.
  ; times_killed = 0
  }

let update_shield (shield : Body.t) (body : Body.t) =
  { shield with pos = body.pos; angle = body.angle }

let update_boost (boost : Body.t) (body : Body.t) (bot : t) =
  let forward = Float.(bot.l_input +. bot.r_input > 0.) in
  let angle = body.angle +. if forward then 0. else Float.pi in
  let pos =
    Vec.add body.pos (Vec.rotate Ctf_consts.Bots.Offense.Boost.offset angle)
  in
  { boost with pos; angle }

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
    t.num_flags <- t.num_flags + 1;
    t.last_flag_return <- ts);
  let multiplier =
    if Float.(ts - t.last_boost <= Ctf_consts.Bots.Offense.boost_time)
    then Ctf_consts.Bots.Offense.boost_power_scale
    else 1.
  in
  Set_motors.apply_motor_force
    body
    ~dt
    ~bot_height:Ctf_consts.Bots.height
    ~force_over_input:Ctf_consts.Bots.Offense.force_over_input
    ~air_resistance_c:Ctf_consts.Bots.air_resistance_c
    ~side_fric_k:Ctf_consts.Bots.side_fric_k
    (t.l_input *. multiplier)
    (t.r_input *. multiplier)

let reset (body : Body.t) start =
  let start_pos = Ctf_consts.Bots.Offense.start_pos in
  let my = Ctf_consts.Bots.Offense.max_restart_y in
  let pos =
    if start
    then start_pos
    else Vec.create start_pos.x (Random.float_range (-.my) my)
  in
  { body with pos; v = Vec.origin; angle = Ctf_consts.Bots.start_angle }

let body =
  reset
    (Body.create
       ~m:Ctf_consts.Bots.mass
       ~collision_group:Ctf_consts.Bots.Offense.coll_group
       Ctf_consts.Bots.shape)
    true

let shield =
  Body.create
    ~m:Float.infinity
    ~collision_group:Ctf_consts.Bots.Offense.Shield.coll_group
    ~black_list:Ctf_consts.Bots.Offense.Shield.off_black_list
    Ctf_consts.Bots.Offense.Shield.shape

let boost =
  Body.create
    ~m:Float.infinity
    ~collision_group:Ctf_consts.Bots.Offense.Boost.coll_group
    ~black_list:Ctf_consts.Bots.Offense.Boost.black_list
    Ctf_consts.Bots.Offense.Boost.shape

let remove_live t ?(num_lives = 1) (offense_bot_body : Body.t) ts =
  t.lives <- t.lives - num_lives;
  if t.lives <= 0
  then (
    t.lives <- Ctf_consts.Bots.Offense.start_lives;
    t.has_flag <- false;
    t.last_kill <- ts;
    if t.num_flags = 0
    then t.times_killed <- 0
    else t.times_killed <- t.times_killed + 1;
    if t.times_killed % Ctf_consts.Bots.Offense.deaths_per_flag = 0
       && t.num_flags > 0
    then t.num_flags <- t.num_flags - 1;
    reset offense_bot_body false)
  else offense_bot_body
