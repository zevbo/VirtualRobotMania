#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "pid.rkt")
(provide defense-bot)

(define load-tick 'nil)
(define (maybe-clear-loading tick-num)
  (cond
    [(and (not (eq? load-tick 'nil))
          (> (- tick-num load-tick) 100))
     (set! load-tick 'nil)
     ]))

(define (my-load-laser tick-num)
  (load-laser)
  (set! load-tick tick-num))

(define (my-shoot-laser)
  (shoot-laser)
  (set! load-tick 'nil))

(define (loading) (not (eq? 'nil load-tick)))

(define (on-tick tick-num)
  (maybe-clear-loading tick-num)
  (cond
    [(not (loading)) (my-load-laser tick-num)]
    [(> (- tick-num load-tick) 10) (my-shoot-laser)]
    )
  )


(define defense-bot
  (make-robot
   "Defense"
   on-tick
   #:body-color 'yellow))
