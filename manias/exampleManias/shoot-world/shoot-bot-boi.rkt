#lang racket
(require "../../../lib/worlds/shoot-world/shoot-world.rkt")
(provide bot-boi)


(define p 0.5)
(define neut-ball-p 1.3)
(define (on-tick tick#)
  (set-radian-mode) ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (cond
    [(front-left-close?)  (set-motors! -1 -0.3)]
    [(front-right-close?) (set-motors! -0.3 -1)]
    [(back-left-close?)  (set-motors! 1 0.3)]
    [(back-right-close?) (set-motors! 0.3 1)]
    [(= (num-balls-left) 0)
     (define angles (angles-to-neutral-balls))
     (define goal-angle 
        (foldl (lambda (a1 a2) (if (> (get-looking-dist a1) (get-looking-dist a2)) a2 a1))
                (first angles) (rest angles)))
     (set-motors! (- 1 (* neut-ball-p goal-angle)) (+ 1 (* neut-ball-p goal-angle)))]
    [(and (< (abs angle) 0.2) (< (dist-to-other-bot) 250))
     (set-motors! 1 1)
     (shoot)]
    [(= (modulo tick# 50) 0) (set! p (+ (/ (random) 4) 0.35))]
    [else (set-motors! (- 1 (* p angle)) (+ 1 (* p angle)))] 
    )
  )


(define bot-boi
  (make-robot
   "Bot Boi" on-tick
   #:body-color "black"
   #:wheel-color "red"
   #:image-url "https://i.ytimg.com/vi/g5XLpXVbJKo/maxresdefault.jpg"
   #:name-color "white"
   ))