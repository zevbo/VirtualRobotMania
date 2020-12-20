open Virtuality2d
open Geo

val generate_border
  :  ?border_width:float
  -> ?shift:Vec.t
  -> energy_ret:float
  -> collision_group:int
  -> float
  -> float
  -> Body.t list
