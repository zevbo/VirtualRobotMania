#lang racket
(require "../basicWorldVisualization.rkt")
(require "../baseWorldLogic.rkt")
(require "../robotVisualization.rkt")
(require "../helpers/canvas-edges.rkt")
(require "../geo/geo.rkt")
(require (prefix-in R- "../robot.rkt"))
(provide make-robot set-world!
         run
         set-motors! change-motor-inputs
         get-left% get-right% get-robot-angle get-vl get-vr
         get-lookahead-dist get-lookbehind-dist)

(struct world:primo (canvas robot))
(define global-world (void))
(define (get-world) global-world)
(define (get-robot)
  (world:primo-robot global-world))


(define DEFAULT_BODY_COLOR "grey")
(define DEFAULT_WHEEL_COLOR "black")
(define WORLD_WIDTH 800)
(define WORLD_HEIGHT 500)

(define (make-robot name
                    #:image-url  [image-url  OPTIONAL_DEFAULT]
                    #:name-color [name-color OPTIONAL_DEFAULT]
                    #:name-font  [name-font  OPTIONAL_DEFAULT]
                    #:body-color  [body-color  DEFAULT_BODY_COLOR]
                    #:wheel-color [wheel-color DEFAULT_WHEEL_COLOR])
  (define robot-image
    (create-robot-img body-color wheel-color name
              #:custom-name-color name-color
              #:custom-name-font name-font
              #:image-url image-url))
  (simple-bot robot-image))

(define (set-world! robot)
  (set!
   global-world
   (world:primo (create-blank-canvas WORLD_WIDTH WORLD_HEIGHT) robot)))

(define EDGES (get-edges WORLD_WIDTH WORLD_HEIGHT
                         #:as-list? #t))
(create-run-function
 run
 []
 (lambda (world)
   (move-bot (world:primo-robot world) 0.7 #:edges EDGES)
   (display-robot
    (world:primo-canvas world)
    (world:primo-robot world)))
 get-world
 [] [])

(define (set-motors! left% right%)
  (R-set-inputs! (world:primo-robot global-world) left% right%))
(define (get-left%)  (R-robot-left%  (get-robot)))
(define (get-right%) (R-robot-right% (get-robot)))
(define (get-vl) (R-robot-vl (get-robot)))
(define (get-vr) (R-robot-vr (get-robot)))
(define (change-motor-inputs Δleft% Δright%)
  (set-motors! (+ (get-left%) Δleft%) (+ (get-right%) Δright%)))
(define (get-robot-angle)
  (R-robot-angle (get-robot)))
(define (get-dists)
  (define pos (R-robot-point (get-robot)))
  (define angle (R-robot-angle (get-robot)))
  (define vision-line (point-angle-form pos angle))
  (define-values (top right bottom left) (get-edges WORLD_WIDTH WORLD_HEIGHT))
  (define (this.intersection line)
    (intersection vision-line line #:empty-value (point +inf.0 +inf.0)))
  (define intTop   (this.intersection top))
  (define intRight (this.intersection right))
  (define intBot   (this.intersection bottom))
  (define intLeft  (this.intersection left))
  (define-values (forHor backHor)
    (if (> (cos angle) 0)
        (values intRight intLeft)
        (values intLeft intRight)))
  (define-values (forVert backVert)
    (if (> (sin angle) 0)
        (values intTop intBot)
        (values intBot intTop)))
  (cons
   (- (min (dist pos forHor)  (dist pos forVert)) (/ ROBOT_LENGTH 2))
   (- (min (dist pos backHor) (dist pos backVert)) (/ ROBOT_LENGTH 2))))
(define (get-lookahead-dist)  (car (get-dists)))
(define (get-lookbehind-dist) (cdr (get-dists)))

;; EXample
#|
(define my-bot (make-robot "simplo"))
(set-world my-bot)
(define (on-tick tick#)
  (cond
    [(= tick# 0) (set-motors! 1 1)])
  (change-motor-inputs
   (/ (- (random) 0.45) 5)
   (/ (- (random) 0.45) 5))
  (cond
    [(< (get-lookahead-dist)  100) (set-motors! -0.8 -0.8)]
    [(< (get-lookbehind-dist) 100) (set-motors! 0.8 0.8)])
  )
(run global-world on-tick)
|#
                             