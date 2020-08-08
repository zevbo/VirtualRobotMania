open! Core
open Geo

let v = Vec.create
let l = Line.create

(* This test just shows off the testing infrastructure *)
let%expect_test "dummy test" =
  let ln = l (v 1. 1.) (v 3. 4.) in
  print_s [%sexp (ln : Line.t)];
  [%expect {| ((pt1 (1 1)) (pt2 (3 4))) |}];
  print_s [%sexp (Line.to_ll ln : Line_like.t)];
  [%expect {| ((pt (1 1)) (dir_vec (2 3)) (flips ())) |}]

let%expect_test "on_line" =
  let l1 = l (v 0. 0.) (v 1. 1.) in
  let l2 = l (v (-1.) 1.) (v 1. (-1.)) in
  let i = Line_like.intersection (Line.to_ll l1) (Line.to_ll l2) in
  print_s [%sexp (i : Vec.t option)];
  (* TODO: this looks like a bug! It should be ((0 0)). *)
  [%expect {| () |}]
