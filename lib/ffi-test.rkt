#lang racket
(require 2htdp/image)
(require ffi/unsafe ffi/unsafe/define)

(define-ffi-definer define-robot-sim
  (ffi-lib "../ocaml/_build/default/librobot_sim"))

(define-robot-sim robotsim_init (_fun -> _void))
(define-robot-sim double_int (_fun _int -> _int))
(define-robot-sim add_bot (_fun -> _int))
(define-robot-sim step (_fun -> _void))
;(define-robot-sim load_bot_image (_fun _int _string -> _void))

(robotsim_init)
(double_int 5)
(double_int 100)
(double_int 100000)

;; (define (set-bot-image i image)
;;   (define filename "/tmp/racket-to-ocaml.png")
;;   (save-image image filename)
;;   (load_bot_image 1 filename)
;;   (delete-file filename))

;(set-bot-image 1 (circle 30 'solid 'green))

(void (step))
(define b1 (add_bot))
(define b2 (add_bot))
(void (step))
(define b3 (add_bot))
(void (step))

(define (loop)
  (void (step))
  (loop))
