open Base
open Expect_test_helpers_core
open Geo

let v = Vec.create
let l = Line_like.line

(* This test just shows off the testing infrastructure *)
let%expect_test "line and line-like" =
  let show v1 v2 =
    let line = l v1 v2 in
    print_s [%sexp (line : Line_like.line Line_like.t)]
  in
  show (v 1. 1.) (v 3. 4.);
  [%expect {|
    ((base    (1 1))
     (dir_vec (2 3))) |}];
  show (v (-1.) 1.) (v 1. (-1.));
  [%expect {|
    ((base    (-1 1))
     (dir_vec (2  -2))) |}];
  show (v 1. (-1.)) (v (-1.) 1.);
  [%expect {|
    ((base    (1  -1))
     (dir_vec (-2 2))) |}];
  show (v 3. (-4.)) (v 1. 0.);
  [%expect {|
    ((base    (3  -4))
     (dir_vec (-2 4))) |}]

let%expect_test "param" =
  let param ll p =
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
  let on_line ll pt =
    let param = Line_like.param_of_proj_point ll pt in
    let result = Line_like.on_line ll pt in
    print_s [%message "" (result : bool) (param : float)]
  in
  (* Let's do a simple line, and a few points on it. *)
  let line = l (v 0. 0.) (v 10. 10.) in
  on_line line (v 1. 1.);
  [%expect {|
    ((result true)
     (param  0.1)) |}];
  on_line line (v 0. 0.);
  [%expect {|
    ((result true)
     (param  0)) |}];
  on_line line (v (-1.) (-1.));
  [%expect {|
    ((result true)
     (param  -0.1)) |}];
  on_line line (v 11. 11.);
  [%expect {|
    ((result true)
     (param  1.1)) |}];
  on_line line (v 1. 3.);
  [%expect {|
    ((result false)
     (param  0.2)) |}];
  (* Now, a line with a different slope: (-2,4) *)
  let line = l (v 3. (-4.)) (v 1. 0.) in
  print_s
    [%sexp
      (Vec.dot (v (-1.) 4.) (v (-2.) 8.) /. Vec.mag_sq (v (-2.) 8.) : float)];
  [%expect {| 0.5 |}];
  print_s [%sexp (line : Line_like.line Line_like.t)];
  [%expect {|
      ((base    (3  -4))
       (dir_vec (-2 4))) |}];
  (* BUG, seems like it handles the case of a non-uniform line wrong *)
  on_line line (v 2. (-2.));
  [%expect {|
    ((result true)
     (param  0.5)) |}]

let%expect_test "intersect" =
  let l1 = l (v (-1.) (-1.)) (v 1. 1.) in
  let l2 = l (v (-1.) 1.) (v 1. (-1.)) in
  let parallel = Line_like.are_parallel l1 l2 in
  let i = Line_like.intersection l1 l2 in
  print_s [%message "" (i : Vec.t option) (parallel : bool)];
  [%expect {| ((i ((0 0))) (parallel false)) |}]

let%expect_test "basic line info" =
  let l1 = Line_like.segment (v 0. 0.) (v 2. 0.) in
  let l2 =
    Line_like.rotate (Line_like.segment (v 0. 0.) (v 2. 0.)) (Float.pi /. 6.)
  in
  let l3 = Line_like.segment (v 1. 1.) (v 1. (-3.)) in
  print_s [%sexp (Line_like.slope_of l1 : float)];
  [%expect {| -0 |}];
  print_s [%sexp (Line_like.slope_of l2 : float)];
  [%expect {| 0.57735026918962562 |}];
  print_s [%sexp (Line_like.slope_of l3 : float)];
  [%expect {| INF |}];
  print_s [%sexp (Line_like.angle_of l1 : float)];
  [%expect {| 0 |}];
  print_s [%sexp (Line_like.angle_of l2 : float)];
  [%expect {| 0.5235987755982987 |}];
  print_s [%sexp (Line_like.angle_of l3 : float)];
  [%expect {| -1.5707963267948966 |}]
