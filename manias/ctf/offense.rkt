#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)

(struct PID (p i d [last-error #:mutable] [output #:mutable]))
(define (add-error pid error)
  (set-PID-output! pid (+ (* (PID-p pid) error) (* (PID-d pid) (- error (PID-last-error pid)))))
  (set-PID-last-error! pid error))
(define (make-PID p i predict)
  (PID p i (* predict p) 0.0 0.0))

(define flag-pid (make-PID 0.006 0.0 10))
(define return-pid (make-PID 0.006 0.0 30))

(define offense-bot
  (make-robot
   "Green offenders"
   (lambda (tick#)
     (define pid-using (if (offense-has-flag?) return-pid flag-pid))
     (define error (if (offense-has-flag?) (normalize-angle (- 180 (get-robot-angle))) (angle-to-flag)))
     (cond
       [(= (modulo tick# 50) 0) (printf "error: ~s ~n" error)]) 
     (add-error pid-using error)
     (define control (PID-output pid-using))
     (set-motors (- 1 control) (+ 1 control)))
   #:body-color 'green))
