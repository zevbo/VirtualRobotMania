open! Core_kernel
open Geo

let v = Vec.create
let s = Line_seg.create

let%expect_test "create and show seg" =
  let show v1 v2 =
    let seg = s v1 v2 in
    let ll = Line_seg.to_ll seg in
    print_s [%message "" (seg : Line_seg.t) (ll : Line_like.t)]
  in
  show (v 1. 1.) (v 3. 3.);
  [%expect
    {|
    ((seg ((pt1 (1 1)) (pt2 (3 3))))
     (ll ((base (2 2)) (offset (-2 -2)) (flips (0.5 -0.5))))) |}]
