#lang racket
(require "../../racket/ctf/offense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(provide offense-bot)
(radians-mode)

(define (set-motors-vec v)
  (set-motors (vec-x v) (vec-y v)))

(define (turn-vec x)
  (vec (- x) x))

(define (on-tick tick-num)
  (define thresh (/ pi 10))
  (define angle (angle-to-flag))
  (println (cons 'angle angle))
  (cond
    [(offense-has-flag?) (set-motors 0. 0.)]
    [(or (> angle thresh) (< angle (- thresh)))
     (set-motors-vec (vec-add
                      (vec 0.3 0.3)
                      (turn-vec (/ angle 3))))]
    [else (set-motors 1. 1.)]
    ))

(define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'green))
