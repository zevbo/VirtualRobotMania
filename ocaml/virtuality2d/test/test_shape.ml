open! Core_kernel
open Geo
open Virtuality2d

let%expect_test _ =
  let s =
    { Shape.edges = []
    ; bounding_box =
        { width = 100.; height = 100.; center = Vec.create 10. 200. }
    }
  in
  print_s [%sexp (s : Shape.t)];
  [%expect {| ((edges ()) (bounding_box ((width 100) (height 100) (center (10 200))))) |}]
