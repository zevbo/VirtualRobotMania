#lang racket
(require "../../racket/ctf/defense.rkt")
(provide defense-bot)

(degrees-mode)
;; uncomment the next line and comment out the above line if you want
;; to work in radians.  Radians is a lot easier if you're going to do
;; trigonometric functions like sin, cos, etc.
;(radians mode)

(struct PID (p i d [last-error #:mutable] [output #:mutable]))
(define (add-error pid error)
  (set-PID-output! pid (+ (* (PID-p pid) error) (* (PID-d pid) (- error (PID-last-error pid)))))
  (set-PID-last-error! pid error))
(define (make-PID p i predict)
  (PID p i (* predict p) 0.0 0.0))

(define follow-pid (make-PID 0.08 0.0 10))

(define (on-tick tick-num)
  (add-error follow-pid (angle-to-opp))
  (define control (PID-output follow-pid))
  (define speed (- (/ (dist-to-opp) 200) 0.5))
  (set-motors (- speed control) (+ speed control))
  (cond
    [(< (abs (angle-to-opp)) (* (if (= (offense-lives-left) (next-laser-power)) 3 (next-laser-power)) 5))
     (shoot-laser)]
    [(< (abs (angle-to-opp)) 25) (load-laser)]))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
