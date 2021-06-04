open! Core_kernel
open! Async_kernel

let group ~log_s =
  let%bind state = Main.init ~log_s in
  let impl protocol f = Csexp_rpc.Implementation.create protocol (f state) in
  let impl' protocol f = Csexp_rpc.Implementation.create' protocol (f state) in
  return
    (Csexp_rpc.Implementation.Group.create
       [ impl Protocol.l_input Main.l_input
       ; impl Protocol.r_input Main.r_input
       ; impl Protocol.set_motors Main.set_motors
       ; impl Protocol.load_laser Main.load_laser
       ; impl Protocol.restock_laser Main.restock_laser
       ; impl Protocol.shoot_laser Main.shoot_laser
       ; impl' Protocol.step Main.step
       ; impl Protocol.boost Main.boost
       ; impl Protocol.just_returned_flag Main.just_returned_flag
       ; impl Protocol.just_killed Main.just_killed
       ; impl Protocol.enhance_border Main.enhance_border
       ; impl Protocol.setup_shield Main.setup_shield
       ; impl Protocol.num_flags Main.num_flags
       ; impl Protocol.angle_to_opp Main.angle_to_opp
       ; impl Protocol.dist_to_opp Main.dist_to_opp
       ; impl Protocol.angle_to_flag Main.angle_to_flag
       ; impl Protocol.dist_to_flag Main.dist_to_flag
       ; impl Protocol.get_angle Main.get_angle
       ; impl Protocol.get_opp_angle Main.get_opp_angle
       ; impl Protocol.just_fired Main.just_fired
       ; impl Protocol.laser_cooldown_left Main.laser_cooldown_left
       ; impl Protocol.just_boosted Main.just_boosted
       ; impl Protocol.boost_cooldown_left Main.boost_cooldown_left
       ; impl Protocol.looking_dist Main.looking_dist
       ; impl Protocol.offense_has_flag Main.offense_has_flag
       ])
