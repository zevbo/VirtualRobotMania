#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(degrees-mode)
;; uncomment the next line and comment out the above line if you want
;; to work in radians.  Radians is a lot easier if you're going to do
;; trigonometric functions like sin, cos, etc.
;(radians mode)

(define (on-tick tick-num)
  (if (< (looking-dist 0) 400)
      (set-motors -0.8 -1)
      (set-motors 1 0.9)))

(define offense-bot
  (make-robot
   "Offense"
   on-tick
   #:body-color 'green))
