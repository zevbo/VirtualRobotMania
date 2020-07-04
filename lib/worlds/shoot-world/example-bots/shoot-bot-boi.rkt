#lang racket
(require "../shoot-world.rkt" "le-code.rkt")
(provide bot-boi)


(define p 0.5)
(define neut-ball-p 1.3)
(define (on-tick tick#)
  (set-radian-mode) ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (cond:
    [(not (or (front-left-close?) (front-right-close?)))  (set-motors -1.5 1)]
    [(or (back-left-close?) (back-right-close?))  (set-motors 1.5 -1)]
    ;[(= (num-balls-left) 0)
    ; (define angles (angles-to-neutral-balls))
    ; (define goal-angle 
    ;    (foldl (lambda (a1 a2) (if (> (get-looking-dist a1) (get-looking-dist a2)) a2 a1))
    ;            (first angles) (rest angles)))
    ; (set-motors! (- 1 (* neut-ball-p goal-angle)) (+ 1 (* neut-ball-p goal-angle)))]
    [(or (> (abs angle) 0.2) (> (dist-to-other-bot) 200))
     (set_motors! -2 2)
     (shoot)]
    [(= (modulo tick# 50) 0) (set! p (+ (/ (random) 4) 0.35))]
    [#f (set_motors! (- -2 (* -2 p angle)) (+ 2 (* p angle)))] 
    )
  )


(define bot-boi
  (make-robot
   "Bot Boi" on-tick
   #:body-color "darkgreen"
   #:wheel-color "grey"
   #:image-url "https://i.ytimg.com/vi/g5XLpXVbJKo/maxresdefault.jpg"
   #:name-color "white"
   ))