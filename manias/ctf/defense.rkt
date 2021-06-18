#lang racket
(require "../../racket/ctf/defense.rkt")
(provide defense-bot)

(degrees-mode)

(define (on-tick tick-num)
  (set-motors 0 0.1))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
