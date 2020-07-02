#lang racket
(require "../../lib/worlds/shoot-world/shoot-world-base.rkt")
(require "shoot-bot-boi.rkt")

(set-radian-mode)

(define p 0.5)
(define (on-tick tick#)
  (define angle (angle-to-other-bot))
  (cond
    [(< (abs angle) 0.1)
     (shoot)]
    [else (set-motors! 0.4 1)] 
    )
  )

(define my-bot
  (make-robot
   "Pelosi Mo-beel" on-tick
   #:body-color "pink"
   #:wheel-color "green"
   #:image-url "https://pyxis.nymag.com/v1/imgs/dea/e96/43d78070c0f7cff46d506c303850980bb0-nancy-pelosi.rsquare.w700.jpg"
   ))

(set-world! my-bot bot-boi)
(run)

#|
(require "../../lib/basicWorldVisualization.rkt")
(require "../../lib/baseWorldLogic.rkt")
(require "../../lib/robotVisualization.rkt")
(require "../../lib/helpers/canvas-edges.rkt")
(require "../../lib/helpers/edge-helpers.rkt")
(require (prefix-in G-"../../lib/geo/geo.rkt"))
(require (prefix-in R-"../../lib/robot.rkt"))
|#