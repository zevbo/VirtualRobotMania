#lang racket
(require "../../racket/ctf/defense.rkt")
(require "../../racket/ctf/vector.rkt")
(require "../../racket/ctf/ll.rkt")
(require "pid.rkt")
(provide defense-bot)

(define load-expiration 100)
(define fire-delay 20)

;; either 'nil, 'almost, 'next, or 'ready
(define shoot-readiness 'nil)

(define (record-shot)
  (println (cons 'record-shot shoot-readiness))
  (cond
    [(eq? shoot-readiness 'ready)
     (set! shoot-readiness 'nil)]))

(define (update-shoot-readiness)
  (cond
    [(and (eq? shoot-readiness 'nil)
          (= (laser-cooldown-left) 0))
     (set! shoot-readiness 'almost)]
    [(eq? shoot-readiness 'almost)
     (set! shoot-readiness 'next)]
    [(eq? shoot-readiness 'next)
     (set! shoot-readiness 'ready)]))

(define (ready-to-shoot)
  (eq? shoot-readiness 'ready))

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
  (record-shot)
  (shoot-laser)
  (set! load-tick 'nil))

(define (loading) (not (eq? 'nil load-tick)))

(define (on-tick tick-num)
  (update-shoot-readiness)
  (println (list (list 'load-tick load-tick)
                 (list 'tick-num tick-num)
                 (list 'laser-cooldown-left (laser-cooldown-left))
                 (list 'shoot-readiness shoot-readiness)
                 ))
  (maybe-clear-loading tick-num)
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
