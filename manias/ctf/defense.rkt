#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(provide defense-bot)

(define (on-tick tick-num)
  (set-motors 0 0.1))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
