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

let%expect_test "on line" =
  let on_line line pt =
    let result = Line_like.on_line (Line.to_ll line) pt in
    print_s [%sexp (result : bool)]
  in
  on_line (l (v 0. 0.) (v 10. 10.)) (v 1. 1.);
  (* BUG! *)
  [%expect {| false |}];
  on_line (l (v 0. 0.) (v 10. 10.)) (v 0. 0.);
  (* BUG! *)
  [%expect {| false |}];
  on_line (l (v 0. 0.) (v 10. 10.)) (v (-1.) (-1.));
  (* BUG! *)
  [%expect {| false |}]

let%expect_test "intersect" =
  let l1 = l (v 0. 0.) (v 1. 1.) in
  let l2 = l (v (-1.) 1.) (v 1. (-1.)) in
  let i = Line_like.intersection (Line.to_ll l1) (Line.to_ll l2) in
  print_s [%sexp (i : Vec.t option)];
  (* TODO: this looks like a bug! It should be ((0 0)). *)
  [%expect {| () |}]
