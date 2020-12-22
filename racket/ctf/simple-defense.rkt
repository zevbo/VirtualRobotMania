#lang racket
(require "defense.rkt")
(provide def1 def2)

(define (on-tick1 tick#)
  (shoot-laser)
  (define p 0.2)
  (define angle (angle-to-opp))
  (define output (* p angle))
  (set-motors (- 1 output) (+ 1 output)))
(define (on-tick2 tick#)
  (shoot-laser)
  (define p 0.5)
  (define angle (angle-to-opp))
  (define output (* p angle))
  (set-motors (- 1 output) (+ 1 output)))

(define def1 (make-robot "Cashu 2.0" on-tick1))
(define def2 (make-robot "Stringer Little" on-tick2))