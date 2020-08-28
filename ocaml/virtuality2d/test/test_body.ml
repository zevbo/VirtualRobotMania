open! Base
open Expect_test_helpers_core
open Geo
open Virtuality2d

let%expect_test _ =
  let s1 = Shape.create_rect 100. 100. (Material.create 1.) in
  let b1 = Body.create s1 1. 200. 25. in
  let b2 =
    Body.create
      s1
      1.
      200.
      ~v:(Vec.create (-2.) 0.)
      ~pos:(Vec.create 100. 0.)
      ~angle:(-0.1)
      25.
  in
  let b3 = { b2 with angle = Float.pi /. 4.; pos = Vec.create 120. 0. } in
  print_s [%sexp ((Body.apply_com_impulse b1 (Vec.create 0. 1.)).v : Vec.t)];
  [%expect {| (0 1) |}];
  print_s [%sexp ((Body.apply_pure_angular_impulse b1 100.).omega : float)];
  [%expect {| 0.5 |}];
  print_s
    [%sexp
      ((Body.apply_impulse b1 (Vec.create 0. 1.) (Vec.create 20. 0.)).omega
        : float)];
  [%expect {| 0.1 |}];
  print_s
    [%sexp
      (List.map (Body.get_edges_w_global_pos b2) ~f:(fun edge -> edge.ls)
        : Line_like.segment Line_like.t list)];
  [%expect
    {|
    (((base    (104.99167  49.750208))
      (dir_vec (-99.500417 9.9833417))
      (flips   (0.5        -0.5)))
     ((base    (149.75021 -4.9916708))
      (dir_vec (9.9833417 99.500417))
      (flips   (0.5       -0.5)))
     ((base    (95.008329 -49.750208))
      (dir_vec (99.500417 -9.9833417))
      (flips   (0.5       -0.5)))
     ((base    (50.249792 4.9916708))
      (dir_vec (9.9833417 99.500417))
      (flips   (0.5       -0.5)))) |}];
  print_s
    [%sexp
      (Line_like.intersection
         (List.nth_exn (Body.get_edges_w_global_pos b1) 1).ls
         (List.nth_exn (Body.get_edges_w_global_pos b2) 3).ls
        : Vec.t option)];
  [%expect {| ((50 2.5020854)) |}];
  print_s
    [%sexp
      (List.map (Body.intersections b1 b2) ~f:(fun inter -> inter.pt)
        : Vec.t list)];
  [%expect {|
    ((50 -45.234312)
     (50 2.5020854)) |}];
  print_s
    [%sexp
      (List.map (Body.intersections b1 b3) ~f:(fun inter -> inter.pt)
        : Vec.t list)];
  [%expect];
  print_s [%sexp (Body.collide b1 b3 : Body.t * Body.t)];
  [%expect]
