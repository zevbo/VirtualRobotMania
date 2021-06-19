#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "shared.rkt")
(provide defense-bot)

(define (on-tick tick-num)
  (towards-zero (angle-to-opp) (vec 0.3 0.3))
  (cond
    [(or (< (angle-to-opp) (/ pi 12))
         (> (angle-to-opp) (- (/ pi 12))))
     (shoot-laser)]))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
