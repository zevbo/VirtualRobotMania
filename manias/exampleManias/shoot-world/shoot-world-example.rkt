#lang racket
(require "../../../lib/worlds/shoot-world/shoot-world.rkt")
(require "shoot-bot-boi.rkt")
(require "eager-shooter.rkt")
(require "the-dagger.rkt")
(require "pelosi-mobeel.rkt")

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
   #:image-url "https://lh3.googleusercontent.com/proxy/haS90_yIisFK55WjWEXZt4Qg0rhObtjz508OyNK4Y3DDHLv6gSRFZGcNfyuJx50d57Plamr8yCR-QUmrgvWqIUVnHWFIgYmNxhHzNX3kInA1tEuJzQ"
   #:name-color "black"
   ))

(set-world! my-bot the-dagger)
(run)