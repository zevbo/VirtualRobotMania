#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(struct PID (p i d [last-error #:mutable] [output #:mutable]))
(define (add-error pid error)
  (set-PID-output! pid (+ (* (PID-p pid) error) (* (PID-d pid) (- error (PID-last-error pid)))))
  (set-PID-last-error! pid error))
(define (make-PID p i predict)
  (PID p i (* predict p) 0.0 0.0))

(define flag-pid (make-PID 0.01 0.0 10))
(define return-pid (make-PID 0.01 0.0 30))

(define offense-bot
  (make-robot
   "Green offenders"
   (lambda (tick#)
     (define pid-using (if (offense-has-flag?) return-pid flag-pid))
     (define backwards? (and (offense-has-flag?) (< (abs (get-robot-angle)) 90)))
     (define robot-angle (normalize-angle (+ (if backwards? 180 0) (get-robot-angle))))
     (define error (if (offense-has-flag?) (normalize-angle (- 180 robot-angle)) (angle-to-flag)))
     (cond
       [(= (modulo tick# 5) 0) (printf "error: ~s~n" error)]) 
     (add-error pid-using error)
     (define control (PID-output pid-using))
     #|(cond
       [(< control -1.8) (set! control -1.8)]
       [(> control 1.8) (set! control 1.8)])|#
     (define default (if backwards? -1 1))
     (define (do-stuff amount)
       (cond
         [(> amount 0)
          (offense-has-flag?)
          (do-stuff (- amount 1))]))
     (do-stuff 5)
     (set-motors (- default control) (+ default control))
     (cond
       [(opp-just-fired?) (boost)]))
   #:body-color 'green))
