open! Base
open! General

type t = {x : float; y : float}

let magSq t = t.x **. t.x +. t.y **. t.y 
let mag t = Float.sqrt (magSq t)
let scale t c = {x = t.x *. c; y = t.y *. c}
let add t1 t2 = {x = t1.x +. t2.x; y = t1.y +. t2.y}
let sub t1 t2 = add t1 (scale t2 (-1.))
let to_unit t = scale t (1. /. (mag t))
let collinear t1 t2 t3 = 
    Float.((Float.abs (((t2.y -. t1.y) *. (t3.x -. t2.x) -. (t2.x -. t1.x) *. (t3.y -. t2.y)))) < General.epsilon)
let distSq t1 t2 = magSq (sub t1 t2)
let dist t1 t2 = Float.sqrt (distSq t1 t2)
let equals ?(epsilon = General.epsilon) t1 t2 = 
    Float.((Float.abs (t1.x -. t2.x)) < epsilon) && 
    Float.((Float.abs (t1.y -. t2.y)) < epsilon)