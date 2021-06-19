#lang racket
(require "../../racket/ctf/offense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(provide offense-bot)



(define (on-tick tick-num)
  (println (cons 'offense (looking-dist 0)))
  (define thresh (/ pi 10))
  (define angle (angle-to-flag))
  (cond
    [(> angle thresh)
     (set-motors -1 1)]
    [(< angle (- thresh))
     (set-motors 1 -1)]
    [else (set-motors 1. 1.)]
    ))

(define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'green))
