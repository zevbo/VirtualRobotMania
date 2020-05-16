#lang racket
(require "../basicWorldVisualization.rkt")
(require "../baseWorldLogic.rkt")
(require "../robotVisualization.rkt")
(require "../helpers/canvas-edges.rkt")
(require "../helpers/edge-helpers.rkt")
(require "../geo/geo.rkt")
(require (prefix-in R- "../robot.rkt"))
(provide make-robot set-world!
         run
         set-motors! change-motor-inputs
         get-left% get-right% get-robot-angle get-vl get-vr
         get-lookahead-dist get-lookbehind-dist get-looking-dist
         get-x get-y
         get-robot edges)

(struct world:primo (canvas robot))
(define global-world (void))
(define (get-world) global-world)
(define (get-robot)
  (world:primo-robot global-world))

(define (get-x) (R-robot-x (get-robot)))
(define (get-y) (R-robot-y (get-robot)))


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

(define INNER_SCALE_FACTOR 0.5)
(define PERCENT_EDGES 0.2)
(define (create-edges)
  (define INNER_WIDTH  (* WORLD_WIDTH INNER_SCALE_FACTOR))
  (define INNER_HEIGHT (* WORLD_HEIGHT INNER_SCALE_FACTOR))
  (define-values (mid-tr mid-br mid-tl mid-bl) (get-corners INNER_WIDTH INNER_HEIGHT))
  (define required-edges (get-edges WORLD_WIDTH WORLD_HEIGHT #:as-list? #t))
  (define optional-edges
    (append
     (get-edges INNER_WIDTH INNER_HEIGHT #:as-list? #t)
     (list
      (line-seg mid-tr (scale-point 0.5 (point INNER_WIDTH WORLD_HEIGHT)))
      (line-seg mid-tr (scale-point 0.5 (point WORLD_WIDTH INNER_HEIGHT)))
     
      (line-seg mid-br (scale-point 0.5 (point INNER_WIDTH (- 0 WORLD_HEIGHT))))
      (line-seg mid-br (scale-point 0.5 (point WORLD_WIDTH (- 0 INNER_HEIGHT))))
     
      (line-seg mid-tl (scale-point 0.5 (point (- 0 INNER_WIDTH) WORLD_HEIGHT)))
      (line-seg mid-tl (scale-point 0.5 (point (- 0 WORLD_WIDTH) INNER_HEIGHT)))
     
      (line-seg mid-bl (scale-point 0.5 (point (- 0 INNER_WIDTH) (- 0 WORLD_HEIGHT))))
      (line-seg mid-bl (scale-point 0.5 (point (- 0 WORLD_WIDTH) (- 0 INNER_HEIGHT)))))))
  (append
   (filter (lambda (_) (< (random) PERCENT_EDGES)) optional-edges)
   required-edges))

(define edges (create-edges))

(define (set-world! robot)
  (set! edges (create-edges))
  (set!
   global-world
   (world:primo (create-walled-canvas WORLD_WIDTH WORLD_HEIGHT edges) robot)))

(create-run-function
 run
 []
 (lambda (world)
   (move-bot (world:primo-robot world) 0.6 #:edges edges)
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
(define (get-dist angle)
  (cdr
   (closest-intersection
    edges (get-robot)
    (ray-point-angle-form (R-robot-point (get-robot)) (+ angle (get-robot-angle))))))
(define (get-lookahead-dist)  (- (get-dist 0) (/ ROBOT_LENGTH 2)))
(define (get-lookbehind-dist) (- (get-dist pi) (/ ROBOT_LENGTH 2)))
(define (get-looking-dist angle)
  (get-dist (degrees->radians angle)))

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
                             