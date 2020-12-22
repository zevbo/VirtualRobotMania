open! Core_kernel
open! Async

let group () =
  let%map state = Main.init () in
  let enhance_border () = Main.enhance_border state in
  let num_flags () = Main.num_flags state in
  let impl = Csexp_rpc.Implementation.create in
  let impl' = Csexp_rpc.Implementation.create' in
  Csexp_rpc.Implementation.Group.create
    [ impl Protocol.l_input (Main.l_input state)
    ; impl Protocol.r_input (Main.r_input state)
    ; impl Protocol.set_motors (Main.set_motors state)
    ; impl Protocol.shoot_laser (Main.shoot_laser state)
    ; impl Protocol.step (Main.step state)
    ; impl Protocol.boost (Main.boost state)
    ; impl Protocol.enhance_border enhance_border
    ; impl' Protocol.set_image (State.set_image state)
    ; impl Protocol.num_flags num_flags
    ; impl Protocol.opp_dist (Main.opp_dist state)
    ; impl Protocol.opp_angle (Main.opp_angle state)
    ]
