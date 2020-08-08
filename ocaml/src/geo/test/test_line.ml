open! Core
open Geo

let v = Vec.create
let l = Line.create

(* This test just shows off the testing infrastructure *)
let%expect_test "line and line-like" =
  let show v1 v2 =
    let line = l v1 v2 in
    let like = Line.to_ll line in
    print_s [%message "" (line : Line.t) (like : Line_like.t)]
  in
  show (v 1. 1.) (v 3. 4.);
  [%expect
    {|
    ((line ((pt1 (1 1)) (pt2 (3 4))))
     (like ((pt (1 1)) (dir_vec (2 3)) (flips ())))) |}];
  show (v (-1.) 1.) (v 1. (-1.));
  [%expect
    {|
    ((line ((pt1 (-1 1)) (pt2 (1 -1))))
     (like ((pt (-1 1)) (dir_vec (2 -2)) (flips ())))) |}];
  show (v 1. (-1.)) (v (-1.) 1.);
  [%expect
    {|
    ((line ((pt1 (1 -1)) (pt2 (-1 1))))
     (like ((pt (1 -1)) (dir_vec (-2 2)) (flips ())))) |}]

let%expect_test "param" =
  let param line p =
    let ll = Line.to_ll line in
    let pt = Line_like.param_to_point ll p in
    let p' = Line_like.param_of ll pt in
    print_s [%message "" (pt : Vec.t) (p' : Float.Terse.t option)]
  in
  let line = l (v 0. 0.) (v 10. 10.) in
  param line 0.;
  [%expect {| ((pt (0 0)) (p' (0))) |}];
  param line 1.;
  [%expect {| ((pt (10 10)) (p' (1))) |}];
  param line 0.5;
  [%expect {| ((pt (5 5)) (p' (0.5))) |}];
  param line (-1.);
  (* BUG *)
  [%expect {| ((pt (-10 -10)) (p' (-1))) |}]

let%expect_test "on line" =
  let on_line line pt =
    let ll = Line.to_ll line in
    let param = Line_like.unsafe_param_of ll pt in
    let result = Line_like.on_line ll pt in
    print_s [%message "" (result : bool) (param : float)]
  in
  let line = l (v 0. 0.) (v 10. 10.) in
  on_line line (v 1. 1.);
  [%expect {| ((result true) (param 0.1)) |}];
  on_line line (v 0. 0.);
  [%expect {| ((result true) (param 0)) |}];
  on_line line (v (-1.) (-1.));
  [%expect {| ((result true) (param -0.1)) |}];
  on_line line (v 11. 11.);
  [%expect {| ((result true) (param 1.1)) |}]

let%expect_test "intersect" =
  let l1 = l (v 0. 0.) (v 1. 1.) in
  let l2 = l (v (-1.) 1.) (v 1. (-1.)) in
  let i = Line_like.intersection (Line.to_ll l1) (Line.to_ll l2) in
  print_s [%sexp (i : Vec.t option)];
  (* BUG *)
  [%expect {| () |}]