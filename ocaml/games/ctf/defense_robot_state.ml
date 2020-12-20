open Virtuality2d
open Common

type t =
  { mutable l_input : float
  ; mutable r_input : float
  }

let create () = { l_input = 0.; r_input = 0. }

let gen_updater t dt =
  let updater (body : Body.t) _world =
    Set_motors.apply_motor_force
      body
      ~dt
      ~bot_height:Bodies.bot_height
      ~force_over_input:Ctf_consts.defense_force_over_input
      ~air_resistance_c:Ctf_consts.air_resistance_c
      ~side_fric_k:Ctf_consts.side_fric_k
      t.l_input
      t.r_input
  in
  updater
