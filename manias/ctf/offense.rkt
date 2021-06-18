#lang racket
(require "../../racket/ctf/offense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(provide offense-bot)

(define (on-tick tick-num)
  (set-motors 0.1 0))

(define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'green))
