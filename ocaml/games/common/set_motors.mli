open Virtuality2d

val apply_motor_force
  :  Body.t
  -> dt:float
  -> bot_height:float
  -> force_over_input:float
  -> air_resistance_c:float
  -> side_fric_k:float
  -> float
  -> float
  -> Body.t
