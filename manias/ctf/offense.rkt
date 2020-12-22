#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(define offense-bot
  (make-robot
   "Green offenders"
   (lambda (tickno)
     (if (< (looking-dist) 400)
         (set-motors -0.8 -1)
         (set-motors 1 0.9)))
   #:body-color 'green))
