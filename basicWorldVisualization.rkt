#lang racket
(require "baseWorldLogic.rkt")
(require "robotVisualization.rkt")
(require "robot.rkt")
(require 2htdp/image)
(require 2htdp/universe)
(provide create-blank-canvas
         create-robot-img
         (struct-out robot)
         simple-bot
         display-robot
         create-run-function)

(define (create-blank-canvas width height)
  (rectangle width height "outline" "black"))

(define (display-robot canvas bot)
  (overlay/offset
   (rotate (radians->degrees (robot-angle bot)) (robot-image bot))
   (- 0 (robot-x bot)) (robot-y bot)
   canvas))

(define my-bot-image (create-robot-img "magenta" "navy" "THE PELOSI MO-BEEL"
              #:custom-name-color "white"))
(define my-bot (simple-bot my-bot-image))
(set-inputs! my-bot 0.2 1)

;; every game must have a world
;; on-tick takes an argument for the world
(define-syntax-rule (create-run-function run-func to-draw-f
                                         [body-start ...] [body-end ...])
  (define (run-func world on-tick-f)
    (big-bang world
      [to-draw to-draw-f]
      [on-tick
       (lambda (world) body-start ... (on-tick-f) body-end ... world)
       TICK_LENGTH])))

(struct world:blank (robot canvas))
(define (create-world:blank robot)
  (world:blank robot (create-blank-canvas 1000 700)))
(create-run-function
 run-world:blank
 (lambda (world)
   (move-bot (world:blank-robot world) 1)
   (display-robot
    (world:blank-canvas world)
    (world:blank-robot world))) [] [])
