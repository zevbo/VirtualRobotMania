open! Base
open Expect_test_helpers_core
open Geo
open Virtuality2d

let%expect_test _ =
  let s1 = Shape.create_rect 100. 100. (Material.create 0.) in
  let b1 = Body.create s1 1. 200. 25. in
  let b2 =
    Body.create
      s1
      1.
      200.
      ~v:(Vec.create (-2.) 0.)
      ~pos:(Vec.create 100. 0.)
      ~angle:0.1
      25.
  in
  print_s [%sexp ((Body.apply_com_impulse b1 (Vec.create 0. 1.)).v : Vec.t)];
  [%expect {| (0 1) |}];
  print_s [%sexp ((Body.apply_pure_angular_impulse b1 100.).omega : float)];
  [%expect {| 0.5 |}];
  print_s
    [%sexp
      ((Body.apply_impulse b1 (Vec.create 0. 1.) (Vec.create 20. 0.)).omega
        : float)];
  [%expect {| 0.1 |}];
  print_s [%sexp (Body.collide b1 b2 : Body.t * Body.t)]
