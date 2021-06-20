#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "pid.rkt")
(provide defense-bot)

;; BASIC MATH

(define (set-motors-vec v) (set-motors (vec-x v) (vec-y v)))
(define (turn-vec x) (vec x (- x)))
(define (acc-vec x) (vec x x))

;; CONSTANTS

(define load-expiration 30)
(define powerup-delay 10)

;; LASER LOADING

(define load-tick 'nil)
(define (maybe-clear-loading tick-num)
  (cond
    [(and (not (eq? load-tick 'nil))
          (> (- tick-num load-tick) load-expiration))
     (set! load-tick 'nil)
     ]))

(define (my-restock-laser)
  #;(println 'restock-laser)
  (set! load-tick 'nil)
  (restock-laser)
  )

(define (my-load-laser tick-num)
  #;(println (list 'loading-laser tick-num))
  (load-laser)
  (set! load-tick tick-num))

(define (will-kill tick-num)
  (or
   (= (offense-lives-left) 1)
   (and
    (loading)
    (>=
     (- tick-num load-tick)
     (* (+ -1 (offense-lives-left)) powerup-delay)))))

(define (my-shoot-laser)
  #;(println (list 'shooting))
  (shoot-laser)
  (set! load-tick 'nil))

(define (loading) (not (eq? 'nil load-tick)))

(define (can-shoot)
  (= (laser-cooldown-left) 0))

;; PIDs

(define opp-angle-pid (pid-init -1.1 5))
(define opp-dist-pid  (pid-init 0.005 5))

(define (rescale-vec v)
  (define s (max 1 (abs (vec-x v)) (abs (vec-y v))))
  (vec (/ (vec-x v) s) (/ (vec-y v) s)))

(define (angle-deviation)
  (abs (angle-to-opp)))

(define (on-tick tick-num)
  (radians-mode)
  (pid-update opp-angle-pid (angle-to-opp))
  ;; we subtract some from the distance so we don't come to close to
  ;; the other car.
  (pid-update opp-dist-pid (- (dist-to-opp) 200))

  (define angle-imp (pid-eval opp-angle-pid))
  (define dist-imp (pid-eval opp-dist-pid))

  (define motor-vec
    (rescale-vec (vec-add (turn-vec angle-imp) (acc-vec dist-imp))))

  #;(println (list (list 'a angle-imp)
                 (list 'd dist-imp)
                 (list 'm motor-vec)))

  (set-motors-vec motor-vec)

  (define shoot-thresh
    (min pi
         (* 15 (/ 1 (dist-to-opp)) (/ pi 4))))
  (define (should-shoot-scale x)
    (define thresh (* shoot-thresh x))
    (< (angle-deviation) thresh))

  #;(println (list (list 'deriv (pid-d opp-angle-pid))
                 (list 'adev (angle-deviation))
                 (list 'shoot-thresh shoot-thresh)
                 ))

  #;(println (list
            (list 'dev (angle-deviation))
            (list 'will-kill (will-kill tick-num))
            ))
  #;(println (list 'angle opp-angle-pid))
  #;(println (list 'dist opp-dist-pid))
  (cond
    [(and (can-shoot) (will-kill tick-num) (should-shoot-scale 1))
     (my-shoot-laser)]
    [(and
      #f
      (not (loading))
      (not (will-kill tick-num))
      (< (abs (pid-d opp-angle-pid)) 0.2)
      (> (dist-to-opp) 100)
      (should-shoot-scale 0.5))
     (my-load-laser tick-num)]
    [(and (not (loading)) (can-shoot) (should-shoot-scale 1.))
     (my-shoot-laser)]
    [(not (should-shoot-scale 10.)) (my-restock-laser)]
    ))

(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
