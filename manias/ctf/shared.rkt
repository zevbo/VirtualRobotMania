#lang racket
(require "../../racket/ctf/offense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "pid.rkt")
(provide (all-defined-out))

(radians-mode)

(define (set-motors-vec v)
  (set-motors (vec-x v) (vec-y v)))

(define (turn-vec x)
  (vec (- x) x))

(define (towards-zero angle base)
  (define thresh (/ pi 10))
  (cond
    [(opp-just-fired?) (boost) (set-motors 1. 1.)]
    [(or (> angle thresh) (< angle (- thresh)))
     (set-motors-vec (vec-add
                      base
                      (turn-vec (max -0.5 (min 0.5 (/ angle 3))))))]
    ))
