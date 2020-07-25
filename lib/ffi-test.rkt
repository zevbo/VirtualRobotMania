#lang racket

(require ffi/unsafe ffi/unsafe/define)

(define-ffi-definer define-robot-sim
  (ffi-lib "../ocaml/_build/default/librobot_sim"))

(define-robot-sim robotsim_init (_fun -> _void))
(define-robot-sim double_int (_fun _int -> _int))

(robotsim_init)
(double_int 5)
(double_int 100)
(double_int 100000)
