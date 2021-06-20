#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "pid.rkt")
(provide defense-bot)

(define load-expiration 30)
(define fire-delay 20)

(define (ready-to-shoot)
  (= (laser-cooldown-left) 0))

(define load-tick 'nil)
(define (maybe-clear-loading tick-num)
  (cond
    [(and (not (eq? load-tick 'nil))
          (> (- tick-num load-tick) load-expiration))
     (set! load-tick 'nil)
     ]))

(define (my-load-laser tick-num)
  (println (list 'loading-laser tick-num))
  (load-laser)
  (set! load-tick tick-num))

(define (my-shoot-laser)
  (println (list 'shooting))
  (shoot-laser)
  (set! load-tick 'nil))

(define (loading) (not (eq? 'nil load-tick)))

(define (on-tick tick-num)
  (define angle-thresh (/ pi 40))
  (println (list (list 'load-tick load-tick)
                 (list 'tick-num tick-num)
                 (list 'laser-cooldown-left (laser-cooldown-left))
                 (list 'angle angle-thresh)
                 (list 'to-opp (angle-to-opp))
                 ))
  (maybe-clear-loading tick-num)
  (cond
    [(> (angle-to-opp) angle-thresh)     (set-motors -0.1 0.1)]
    [(< (angle-to-opp) (- angle-thresh)) (set-motors 0.1 -0.1)]
    [ else (set-motors 0 0)])
  (cond
    [(and
      (ready-to-shoot)
      (not (loading)))
     (my-load-laser tick-num)]
    [(and (loading)
          (> (- tick-num load-tick) fire-delay))
     (my-shoot-laser)]
    )
  )


(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
