#lang racket
(require "../../../lib/worlds/shoot-world/shoot-world.rkt")
(require "shoot-bot-boi.rkt")
(require "eager-shooter.rkt")
(require "the-dagger.rkt")
(require "pelosi-mobeel.rkt")



(set-world! eager-shooter the-dagger)
(run)
 
#|
(require "../../lib/basicWorldVisualization.rkt")
(require "../../lib/baseWorldLogic.rkt")
(require "../../lib/robotVisualization.rkt")
(require "../../lib/helpers/canvas-edges.rkt")
(require "../../lib/helpers/edge-helpers.rkt")
(require (prefix-in G-"../../lib/geo/geo.rkt"))
(require (prefix-in R-"../../lib/robot.rkt"))
(define ball1 (first (world:shoot-balls (get-world))))
(define ball2 (second (world:shoot-balls (get-world))))
(and (number? (ball-type ball1))
          (maps-intersect? (robot-edges (get-#robot (- 3 (ball-type ball1))))
                           (ball-edges ball1)))
|#