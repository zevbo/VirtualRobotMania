open Base

(* this type is undoubtubly restrictive, but I believe it gives us a reasonable
   amount of flexibility for this 2d virtual robotics *)
type t = { energy_ret : float } [@@deriving sexp_of]

let create energy_ret = { energy_ret }
let energy_ret_of t1 t2 = Float.sqrt (t1.energy_ret *. t2.energy_ret)
