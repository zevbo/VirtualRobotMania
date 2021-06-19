#lang racket
(require "../../racket/ctf/offense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "shared.rkt")
(require "pid.rkt")
(provide offense-bot)
(radians-mode)

#|
(define (on-tick tick-num)
  (define angle (angle-to-flag))
  (set-motors 1. 1.)
  (cond
    [(offense-has-flag?) (towards-zero (get-robot-angle) (vec 0.3 0.3))]
    [else (towards-zero (angle-to-flag) (vec 0.3 0.3))]
    ))
|#

(define flag-angle-pid (pid-init  0.2 0 0))
(define back-angle-pid (pid-init  -0.1 0 0))
(define flag-dist-pid  (pid-init  1   0 0))


(define (normalize v)
  (define m (max (abs (vec-x v)) (abs (vec-y v))))
  (cond
    [(> m 1) (vec (/ (vec-x v) m) (/ (vec-y v) m))]
    [else v]))

(define (normalize-radians theta)
  (cond
    [(> theta pi) (normalize-radians (- theta (* pi 2)))]
    [(< theta (- pi)) (normalize-radians (+ theta (* pi 2)))]
    [ else theta]))

(define (robot-angle)
  (normalize-radians (+ pi (get-robot-angle))))

(define (on-tick tick-num)
  (cond [(opp-just-fired?) (boost)])
  (pid-update flag-angle-pid (angle-to-flag))
  (pid-update back-angle-pid (robot-angle))
  (pid-update flag-dist-pid (dist-to-flag))
  (println (robot-angle))
  (define turn
    (cond
      [(offense-has-flag?)
       (turn-vec (pid-eval back-angle-pid))]
      [else
       (turn-vec (pid-eval flag-angle-pid))]))
  (define speed
    (cond
      [(offense-has-flag?)  (vec 1. 1.)]
      [else
       (define x (max -1 (min 1 (pid-eval flag-dist-pid))))
       (vec x x)]))
  (define action (normalize (vec-add turn speed)))
  (println (cons 'action action))
  (set-motors-vec action)
  )

  (define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'cyan))
