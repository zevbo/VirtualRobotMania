open! Base

let imp_equals ~epsilon n1 n2 = Float.O.(abs (n1 - n2) < epsilon)

let imp_equals_angle ~epsilon n1 n2 =
  let f = Angle.to_radians in
  imp_equals ~epsilon (f n1) (f n2)
