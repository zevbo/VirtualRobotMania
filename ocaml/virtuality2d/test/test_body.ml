open! Base
open Expect_test_helpers_core
open Geo
open Virtuality2d

let%expect_test _ =
  let s1 = Shape.create_rect 100. 100. (Material.create 1.) in
  let s2 = Shape.create_rect 100. 100. (Material.create 0.) in
  let s3 = Shape.create_rect 100. 100. (Material.create 0.5) in
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
  let b3 = { b2 with angle = Float.pi /. 4.; pos = Vec.create 120.7 0. } in
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
  [%expect {|
    ((50 0.010678119)
     (50 -0.010678119)) |}];
  let get_vels (bodies : Body.t * Body.t) =
    match bodies with
    | body1, body2 -> body1.v, body2.v
  in
  print_s [%sexp (get_vels (Body.collide b1 b3) : Vec.t * Vec.t)];
  [%expect {|
    ((-1.9999989     2.4492922E-16)
     (-1.1402215E-06 0)) |}];
  print_s
    [%sexp
      (get_vels (Body.collide { b1 with shape = s2 } { b3 with shape = s2 })
        : Vec.t * Vec.t)];
  [%expect {|
    ((-0.99999944 1.2246461E-16)
     (-1.0000006  0)) |}];
  print_s
    [%sexp
      (get_vels (Body.collide { b1 with shape = s3 } { b3 with shape = s3 })
        : Vec.t * Vec.t)];
  [%expect {|
    ((-1.7071058  2.0906017E-16)
     (-0.29289419 0)) |}];
  print_s
    [%sexp
      (List.map
         ~f:(fun inter -> inter.pt)
         (Body.intersections b1 { b3 with pos = Vec.create 120.7 40.0 })
        : Vec.t list)];
  [%expect {|
    ((50 40.010678)
     (50 39.989322)) |}];
  let get_v_pt (collision : Body.collision) =
    match collision with
    | { t1; t2; impulse_pt; t1_acc_angle; impulse_mag = _; debug = _ } ->
      let calculate t =
        Vec.dot (Body.get_v_pt t impulse_pt) (Vec.unit_vec t1_acc_angle)
      in
      calculate t1, calculate t2
  in
  let collided_bodies_1 =
    Option.value_exn
      (Body.get_collision
         { b1 with shape = s2 }
         { b3 with pos = Vec.create 120. 40.0; shape = s2 })
  in
  print_s [%sexp (get_v_pt collided_bodies_1 : float * float)];
  [%expect{| (1.805132940270928 1.8051328614213928) |}];
  print_s [%sexp (collided_bodies_1.t1.omega : float)];
  [%expect{| 0.039565950208509927 |}];
  print_s
    [%sexp
      (get_vels (collided_bodies_1.t1, collided_bodies_1.t2) : Vec.t * Vec.t)];
  [%expect{|
    ((-0.19437628 2.3804229E-17)
     (-1.8056237  0)) |}];
  print_s [%sexp (collided_bodies_1.impulse_pt : Vec.t)];
  [%expect{| (50 40.710678) |}]
