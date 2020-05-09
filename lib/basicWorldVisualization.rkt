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
(define-syntax-rule (create-run-function run-func [body-initialize ...] to-draw-f get-world-f
                                         [body-start ...] [body-end ...])
  (begin
    (define tick# 0)
    (define (run-func on-tick-f)
      body-initialize ...
      (big-bang (get-world-f)
        [to-draw to-draw-f]
        [on-tick
         (lambda (world) body-start ... (on-tick-f tick#) body-end ...
           (set! tick# (+ tick# 1)) world)
         TICK_LENGTH]))))