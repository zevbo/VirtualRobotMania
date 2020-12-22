open! Core_kernel
open! Async

let group () =
  let%map state = Main.init () in
  let enhance_border () = Main.enhance_border state in
  let setup_shield () = Main.setup_shield state in
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
    ; impl Protocol.setup_shield setup_shield
    ; impl' Protocol.set_image (State.set_image state)
    ; impl Protocol.num_flags num_flags
    ; impl Protocol.dist_to_opp (Main.dist_to_opp state)
    ; impl Protocol.angle_to_opp (Main.angle_to_opp state)
    ; impl Protocol.angle_to_opp (Main.angle_to_opp state)
    ; impl Protocol.dist_to_opp (Main.dist_to_opp state)
    ; impl Protocol.angle_to_flag (Main.angle_to_flag state)
    ; impl Protocol.dist_to_flag (Main.dist_to_flag state)
    ; impl Protocol.get_angle (Main.get_angle state)
    ; impl Protocol.get_opp_angle (Main.get_opp_angle state)
    ; impl Protocol.just_fired (Main.just_fired state)
    ; impl Protocol.laser_cooldown_left (Main.laser_cooldown_left state)
    ; impl Protocol.just_boosted (Main.just_boosted state)
    ; impl Protocol.boost_cooldown_left (Main.boost_cooldown_left state)
    ; impl Protocol.looking_dist (Main.looking_dist state)
    ]
