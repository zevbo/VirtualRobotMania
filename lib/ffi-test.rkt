#lang racket

(require ffi/unsafe ffi/unsafe/define)

(define-ffi-definer define-robot-sim
  (ffi-lib "../ocaml/_build/default/librobot_sim"))

(define-robot-sim robotsim_init (_fun -> _void))
(define-robot-sim double_int (_fun _int -> _int))
(define-robot-sim add_bot (_fun -> _int))
(define-robot-sim step (_fun -> _void))

(robotsim_init)
(double_int 5)
(double_int 100)
(double_int 100000)
(define b1 (add_bot))
(define b2 (add_bot))
(sleep 1)
(void (step))
(sleep 1)
(define b3 (add_bot))
(void (step))
(sleep 1)
