#lang racket
(require "../../racket/ctf/defense.rkt")
(provide defense-bot)

(define defense-bot
  (make-robot
   "Purple Defenders"
   (lambda (tickno)
     (set-motors 1 -1)
     (shoot-laser))
   #:body-color 'yellow))
