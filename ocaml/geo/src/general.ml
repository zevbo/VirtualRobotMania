open! Base

let imp_equals ~epsilon n1 n2 = Float.O.(abs (n1 - n2) < epsilon)
