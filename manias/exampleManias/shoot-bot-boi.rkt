#lang racket
(require "../../lib/worlds/shoot-world/shoot-world-base.rkt")
(provide bot-boi)

(set-radian-mode)

(define p 0.5)
(define (on-tick tick#)
  (define angle (angle-to-other-bot))
  (cond
    [(< (abs angle) 0.1)
     (set-motors! 1 1)
     (shoot)]
    [else (set-motors! (- 1 (* p angle)) (+ 1 (* p angle)))] 
    )
  )


(define bot-boi
  (make-robot
   "Bot Boi" on-tick
   #:body-color "black"
   #:wheel-color "red"
   #:image-url "https://i.ytimg.com/vi/g5XLpXVbJKo/maxresdefault.jpg"

   ))