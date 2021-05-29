open! Core_kernel
open! Async_kernel

let group (module Display : Geo_graph.Display_intf.S) ~root =
  let module State = State.Make (Display) in
  let module Main = Main.Make (Display) in
  let state = Main.init ~root in
  let enhance_border () = Main.enhance_border state in
  let setup_shield () = Main.setup_shield state in
  let just_returned_flag () = Main.just_returned_flag state in
  let just_killed () = Main.just_killed state in
  let num_flags () = Main.num_flags state in
  let impl = Csexp_rpc.Implementation.create in
  let impl' = Csexp_rpc.Implementation.create' in
  Csexp_rpc.Implementation.Group.create
    [ impl Protocol.l_input (Main.l_input state)
    ; impl Protocol.r_input (Main.r_input state)
    ; impl Protocol.set_motors (Main.set_motors state)
    ; impl Protocol.load_laser (Main.load_laser state)
    ; impl Protocol.restock_laser (Main.restock_laser state)
    ; impl Protocol.shoot_laser (Main.shoot_laser state)
    ; impl Protocol.step (Main.step state)
    ; impl Protocol.boost (Main.boost state)
    ; impl Protocol.just_returned_flag just_returned_flag
    ; impl Protocol.just_killed just_killed
    ; impl Protocol.enhance_border enhance_border
    ; impl Protocol.setup_shield setup_shield
    ; impl' Protocol.set_image (State.set_image state)
    ; impl' Protocol.set_image_contents (State.set_image_contents state)
    ; impl Protocol.num_flags num_flags
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
