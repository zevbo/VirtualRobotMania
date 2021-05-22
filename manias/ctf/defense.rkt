#lang racket
(require "../../racket/ctf/defense.rkt")
(provide defense-bot)

(degrees-mode)
;; uncomment the next line and comment out the above line if you want
;; to work in radians.  Radians is a lot easier if you're going to do
;; trigonometric functions like sin, cos, etc.
;(radians mode)

(define (on-tick tick-num)
  (set-motors 1 -1)
  (shoot-laser))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
