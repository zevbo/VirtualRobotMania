#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "pid.rkt")
(provide defense-bot)

(define (set-motors-vec v) (set-motors (vec-x v) (vec-y v)))
(define (turn-vec x) (vec x (- x)))
(define (acc-vec x) (vec x x))

;; For degrees mode
; (define opp-angle-pid (pid-init -0.01 5))
; (define opp-dist-pid  (pid-init 0.004 5))

(define opp-angle-pid (pid-init -0.6 5))
(define opp-dist-pid  (pid-init 0.004 5))

(define load-tick 'nil)

(define (rescale-vec v)
  (define s (max 1 (abs (vec-x v)) (abs (vec-y v))))
  (vec (/ (vec-x v) s) (/ (vec-y v) s)))

(define (on-tick tick-num)
  (radians-mode)
  (pid-update opp-angle-pid (angle-to-opp))
  (pid-update opp-dist-pid (dist-to-opp))

  (define angle-imp (pid-eval opp-angle-pid))
  (define dist-imp (pid-eval opp-dist-pid))

  (define motor-vec
    (rescale-vec (vec-add (turn-vec angle-imp) (acc-vec dist-imp))))

  #;(println (list (list 'a angle-imp)
                 (list 'd dist-imp)
                 (list 'm motor-vec)))

  (set-motors-vec motor-vec)

  (define a (angle-to-opp))
  (define shoot-thresh
    (min pi
         (* 20 (/ 1 (dist-to-opp)) (/ pi 4))))
  (define (should-shoot x)
    (define thresh (* shoot-thresh x))
    (and (< a thresh)
         (> a (- thresh))))
  #;(println (list (list 'angle a)
                 (list 'should should-shoot)
                 (list 'thresh shoot-thresh)))
  (cond [(should-shoot 0.5)
         (load-laser)
         (set! load-tick )])
  (cond
    [(should-shoot 1.) (shoot-laser)]))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
