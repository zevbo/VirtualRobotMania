(* this type is undoubtubly restrictive, but I believe it gives us a
   reasonable amount of flexibility for this 2d virtual robotics *)
type t = { energy_ret : float }

let energy_ret_of t1 t2 = sqrt (t1.energy_ret *. t2.energy_ret)
