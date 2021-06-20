#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(degrees-mode)

(define (on-tick tick-num)
  (cond
    [(not (offense-has-flag?))
     (cond
       [(or (< (angle-to-flag) 0) (=  (angle-to-flag) 0))
        (set-motors 1 0.8)]
       [(> (angle-to-flag) 0)
        (set-motors  0.8 1)]
       )]
    [else
     (cond
       [ (> (abs (get-robot-angle)) 160)
         (set-motors 1 1)]
       )]))


(define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'green))
