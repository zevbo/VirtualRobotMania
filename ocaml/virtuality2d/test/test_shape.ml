open! Base
open Expect_test_helpers_core
open Geo
open Virtuality2d

let%expect_test _ =
  let mat1 = Material.create ~energy_ret:1.0 in
  let s1 =
    Shape.create_standard_rect
      100.
      100.
      ~com:(Vec.create 10. 200.)
      ~material:mat1
  in
  let tr = Vec.create 100. 100. in
  let tl = Vec.create (-100.) 100. in
  let bl = Vec.create (-100.) (-100.) in
  let br = Vec.create 100. (-100.) in
  let og = Vec.create 0. 0. in
  let right = Vec.create 200. 0. in
  let s2 =
    Shape.create_closed
      ~points:[ tr; tl; bl; br ]
      ~material:mat1
      ~average_r:75.
      ~inertia_over_mass:100.
  in
  let s3 =
    Shape.create
      ~edges:[ Edge.create (Line_like.segment og right) mat1 ]
      ~average_r:75.
      ~inertia_over_mass:100.
  in
  print_s [%sexp (s1 : Shape.t)];
  [%expect
    {|
      ((edges (
         ((ls (
            (base    (-10  -150))
            (dir_vec (-100 0))
            (flips   (0.5  -0.5))))
          (material ((energy_ret 1))))
         ((ls (
            (base    (40  -200))
            (dir_vec (0   100))
            (flips   (0.5 -0.5))))
          (material ((energy_ret 1))))
         ((ls (
            (base    (-10 -250))
            (dir_vec (100 0))
            (flips   (0.5 -0.5))))
          (material ((energy_ret 1))))
         ((ls (
            (base    (-60 -200))
            (dir_vec (0   100))
            (flips   (0.5 -0.5))))
          (material ((energy_ret 1))))))
       (bounding_box (
         (width  100)
         (height 100)
         (center (-10 -200))))
       (average_r         NAN)
       (inertia_over_mass 67066.666666666672)) |}];
  print_s [%sexp (s2.bounding_box : Rect.t)];
  [%expect {|
    ((width  200)
     (height 200)
     (center (0 0))) |}];
  print_s [%sexp (s3.bounding_box : Rect.t)];
  [%expect {|
    ((width  200)
     (height 0)
     (center (100 0))) |}]
