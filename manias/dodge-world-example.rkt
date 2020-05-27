#lang racket
(require "../lib/worlds/dodge-world.rkt")

(define my-bot
  (make-robot
   "Pelosi Mo-beel"
   #:body-color "pink"
   #:wheel-color "green"
   #:image-url "https://pyxis.nymag.com/v1/imgs/dea/e96/43d78070c0f7cff46d506c303850980bb0-nancy-pelosi.rsquare.w700.jpg"
   ))

(define (ball-polar-pos ball-id)
  (define angle (angle-to-ball ball-id))
  (cons angle (get-looking-dist angle)))

(define (on-tick tick#)
  ;(set-motors! 0 0)
  (define ball-polar-poses (map ball-polar-pos (range num-balls)))
  (cond
    [(empty? ball-polar-poses) (set-motors! 0 0)]
    [else
     (define closest-ball
       (foldl (lambda (a b) (if (< (cdr a) (cdr b)) a b))
              (first ball-polar-poses) (rest ball-polar-poses)))
     (define angle (car closest-ball))
     (define speed (if (> (abs angle) 90) 0 1))
     (define turning-speed (/ angle 200))
     (cond
       [(< (get-lookahead-dist)  60) (set! speed (min speed -0.1))]
       [(< (get-lookbehind-dist) 60) (set! speed (max speed 0.1))])
     (cond
       [(< (min (get-lookahead-dist) (get-lookbehind-dist)) 100)
        (set! turning-speed (* turning-speed 2))])
     (set-motors! (- speed turning-speed) (+ speed turning-speed))])
  
  )

(set-world! my-bot)
(void (run on-tick))