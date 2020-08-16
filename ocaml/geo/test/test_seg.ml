open! Core_kernel
open Geo

let v x y = Vec.create (Int.to_float x) (Int.to_float y)
let s a b = Line_like.segment a b
let r a b = Line_like.ray a b

let%expect_test "create and show seg" =
  let show v1 v2 =
    let seg = Line_like.segment v1 v2 in
    print_s [%sexp (seg : Line_like.segment Line_like.t)]
  in
  show (v 1 1) (v 3 3);
  [%expect
    {|
    ((base (2 2)) (dir_vec (-2 -2)) (flips (0.5 -0.5)) (kind Segment)) |}]

let%expect_test "intersection" =
  let intersect ll1 ll2 =
    print_s [%sexp (Line_like.intersection ll1 ll2 : Vec.t option)]
  in
  intersect (s (v (-1) (-1)) (v 1 1)) (s (v (-1) 1) (v 1 (-1)));
  [%expect {| ((0 0)) |}];
  intersect (s (v 0 4) (v 4 0)) (s (v 4 4) (v 0 1));
  [%expect {| ((1.7142857 2.2857143)) |}];
  intersect (s (v 0 0) (v 4 4)) (s (v 10 0) (v 0 10));
  [%expect {| () |}];
  intersect (s (v 0 0) (v 6 6)) (s (v 10 0) (v 0 10));
  [%expect {| ((5 5)) |}];
  intersect (s (v 0 0) (Vec.create 5.01 5.01)) (s (v 10 0) (v 0 10));
  [%expect {| ((5 5)) |}];
  intersect (s (v 0 0) (Vec.create 5. 5.)) (s (v 10 0) (v 0 10));
  (* Mildly surprising that this doesn't cause an intersection,
     but not a big deal *)
  [%expect {| () |}];
  (* We can also intersect a ray and a segment. *)
  intersect (s (v 10 0) (v 0 10)) (r (v 0 0) (v 1 1));
  [%expect {| ((5 5)) |}];
  intersect (s (v 10 0) (v 0 10)) (r (v 0 0) (v 1 2));
  [%expect {| ((3.3333333 6.6666667)) |}]
