#lang racket
(require "../../../lib/worlds/shoot-world/shoot-world.rkt")
(require "../../../lib/worlds/shoot-world/example-bots/example-bots.rkt")


(define (on-tick tick#)
  (set-radian-mode) ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (cond
    [(or (front-left-close?) (front-right-close?)) (set-motors! -1 -1)]
    [else (set-motors! 0.8 1)]
    )
  )


(define my-bot
  (make-robot
   "A Robot" on-tick
   #:body-color "blue"
   #:wheel-color "black"
   #:image-url "https://i.pinimg.com/originals/02/0d/08/020d08c863f0742e40a11585c26f2f21.png"
   #:name-color "black"
   ))

(set-world! pelosi-mobeel eager-shooter)
(run)
(set-world! bot-boi the-dagger)
(run)