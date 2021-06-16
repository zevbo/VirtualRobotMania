#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(define offense-bot
  (make-robot
   "Green offenders"
   (lambda (tick#)
     (set-motors 0 0))
   #:body-color 'green))
