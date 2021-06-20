#lang racket
(require "../../racket/ctf/offense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "shared.rkt")
(require "pid.rkt")
(provide offense-bot)

(define (on-tick tick-num) 'nil)

(define offense-bot
  (make-robot
   "Cyan offenders"
   on-tick
   #:body-color 'chartreuse))
