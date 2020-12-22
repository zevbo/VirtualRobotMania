#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(define offense-bot
  (make-robot
   "Green offenders"
   (lambda (tickno)
     (set-motors 1 0.3))
   #:body-color 'green))
