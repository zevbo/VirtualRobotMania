open! Core_kernel
open Geo

let v x y = Vec.create (Int.to_float x) (Int.to_float y)
let s = Line_seg.create

let%expect_test "create and show seg" =
  let show v1 v2 =
    let seg = s v1 v2 in
    let ll = Line_seg.to_ll seg in
    print_s [%message "" (seg : Line_seg.t) (ll : Line_like.t)]
  in
  show (v 1 1) (v 3 3);
  [%expect
    {|
    ((seg ((pt1 (1 1)) (pt2 (3 3))))
     (ll ((base (2 2)) (dir_vec (-2 -2)) (flips (0.5 -0.5))))) |}]

let%expect_test "intersection" =
  let intersect s1 s2 =
    print_s
      [%sexp
        (Line_like.intersection (Line_seg.to_ll s1) (Line_seg.to_ll s2)
          : Vec.t option)]
  in
  intersect (s (v (-1) (-1)) (v 1 1)) (s (v (-1) 1) (v 1 (-1)));
  [%expect {| ((0 0)) |}];
  intersect (s (v 0 4) (v 4 0)) (s (v 4 4) (v 0 1));
  [%expect {| ((1.7142857 2.2857143)) |}]
