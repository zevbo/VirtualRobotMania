#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(define (on-tick tick#)
  (set-motors 0 0))

(define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'green))
