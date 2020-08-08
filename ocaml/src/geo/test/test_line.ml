open! Core
open Geo

(* This test just shows off the testing infrastructure *)
let%expect_test "dummy test" =
  let p = Vec.create in
  let l = Line.create (p 1. 1.) (p 3. 4.) in
  print_s [%sexp (l : Line.t)];
  [%expect {| ((pt1 (1 1)) (pt2 (3 4))) |}]
