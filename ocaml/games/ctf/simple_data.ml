open Core_kernel

type t =
  { offense_has_flag : bool
  ; angle_to_opp : float
  ; dist_to_opp : float
  ; angle_to_flag : float
  ; dist_to_flag : float
  ; get_angle : float
  ; get_opp_angle : float
  ; just_fired : bool
  ; laser_cooldown_left : int
  ; just_boosted : bool
  ; boost_cooldown_left : int
  ; next_laser_power : int
  ; lives_left : int
  ; l_input : float
  ; r_input : float
  }
[@@deriving sexp]
