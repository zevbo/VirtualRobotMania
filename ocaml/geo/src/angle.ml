open! Base

(* The representation is in radians *)

let of_radians x = x
let to_radians x = x
let to_degrees x = x *. 180. /. Float.pi
let of_degrees x = x *. Float.pi /. 180.

include Float

let scale t x = t *. x
