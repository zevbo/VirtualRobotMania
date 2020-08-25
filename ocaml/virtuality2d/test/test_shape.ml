open! Base
open Expect_test_helpers_core
open Geo
open Virtuality2d

let%expect_test _ =
  let s1 =
    { Shape.edges = []
    ; bounding_box =
        { width = 100.; height = 100.; center = Vec.create 10. 200. }
    }
  in
  let tr = Vec.create 100. 100. in
  let tl = Vec.create (-100.) 100. in
  let bl = Vec.create (-100.) (-100.) in
  let br = Vec.create 100. (-100.) in
  let og = Vec.create 0. 0. in
  let right = Vec.create 200. 0. in
  let mat1 = Material.create 1.0 in
  let s2 = Shape.create_closed [ tr; tl; bl; br ] mat1 in
  let s3 = Shape.create [ Edge.create (Line_like.segment og right) mat1 ] in
  print_s [%sexp (s1 : Shape.t)];
  [%expect
    {|
      ((edges ())
       (bounding_box (
         (width  100)
         (height 100)
         (center (10 200))))) |}];
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
