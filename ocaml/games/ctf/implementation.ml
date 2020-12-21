open! Core_kernel
open! Async

let group () =
  let%map state = Main.init () in
  let step () = Main.step state in
  let set_motors (x, y) = Main.set_motors state x y in
  let l_input () = Main.l_input state in
  let r_input () = Main.r_input state in
  let use_offense_bot () = Main.use_offense_bot state in
  let use_defense_bot () = Main.use_defense_bot state in
  let shoot_laser () = Main.shoot_laser state in
  let boost () = Main.boost state in
  let enhance_border () = Main.enhance_border state in
  let set_offense_image s = State.load_offense_image state s in
  let set_defense_image s = State.load_defense_image state s in
  let impl = Csexp_rpc.Implementation.create in
  let impl' = Csexp_rpc.Implementation.create' in
  Csexp_rpc.Implementation.Group.create
    [ impl Protocol.l_input l_input
    ; impl Protocol.r_input r_input
    ; impl Protocol.set_motors set_motors
    ; impl Protocol.shoot_laser shoot_laser
    ; impl Protocol.step step
    ; impl Protocol.use_defense_bot use_defense_bot
    ; impl Protocol.use_offense_bot use_offense_bot
    ; impl Protocol.boost boost
    ; impl Protocol.enhance_border enhance_border
    ; impl' Protocol.set_offense_image set_offense_image
    ; impl' Protocol.set_defense_image set_defense_image
    ]
