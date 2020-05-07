#lang racket
(require "basicWorldVisualization.rkt")
(require "baseWorldLogic.rkt")
(require "robotVisualization.rkt")
(require "helpers/geo.rkt")
(require (prefix-in R- "robot.rkt"))
(provide make-robot set-world
         run
         set-motors! change-motor-inputs
         get-left% get-right% get-robot-angle
         get-lookahead-dist get-lookbehind-dist)

(struct world:primo (canvas robot))
(define global-world (void))
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

(define (set-world robot)
  (set!
   global-world
   (world:primo (create-blank-canvas WORLD_WIDTH WORLD_HEIGHT) robot)))

(create-run-function
 run
 (lambda (world)
   (move-bot (world:primo-robot world) 1)
   (display-robot
    (world:primo-canvas world)
    (world:primo-robot world))) [] [])

(define (set-motors! left% right%)
  (R-set-inputs! (world:primo-robot global-world) left% right% #:max 0.5))
(define (get-left%)  (R-robot-left%  (get-robot)))
(define (get-right%) (R-robot-right% (get-robot)))
(define (change-motor-inputs Δleft% Δright%)
  (set-motors! (+ (get-left%) Δleft%) (+ (get-right%) Δright%)))
(define (get-robot-angle)
  (R-robot-angle (get-robot)))
(define (get-dists)
  (define bot (get-robot))
  (define pos (R-robot-point bot))
  (define angle (R-robot-angle bot))
  (define vision-line (point-angle-form pos angle))
  (define tr (point (/ WORLD_WIDTH  2) (/ WORLD_HEIGHT  2)))
  (define br (point (/ WORLD_WIDTH  2) (/ WORLD_HEIGHT -2)))
  (define tl (point (/ WORLD_WIDTH -2) (/ WORLD_HEIGHT  2)))
  (define bl (point (/ WORLD_WIDTH -2) (/ WORLD_HEIGHT -2)))
  (define hor? (= (sin (R-robot-angle bot)) 0))
  (define ver? (= (cos (R-robot-angle bot)) 0))
  (define inf-p (point +inf.0 +inf.0))
  (define intTop   (if hor? inf-p (intersection vision-line (line tr tl))))
  (define intRight (if ver? inf-p (intersection vision-line (line br tr))))
  (define intBot   (if hor? inf-p (intersection vision-line (line bl br))))
  (define intLeft  (if ver? inf-p (intersection vision-line (line tl bl))))
  (define-values (forHor backHor)
    (if (> (cos angle) 0)
        (values intRight intLeft)
        (values intLeft intRight)))
  (define-values (forVert backVert)
    (if (> (sin angle) 0)
        (values intTop intBot)
        (values intBot intTop)))
  (cons
   (- (min (dist pos forHor) (dist pos forVert)) (/ ROBOT_LENGTH 2))
   (- (min (dist pos backHor) (dist pos backVert)) (/ ROBOT_LENGTH 2))))
(define (get-lookahead-dist)  (car (get-dists)))
(define (get-lookbehind-dist) (cdr (get-dists)))

;; EXample
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
    [(< (get-lookbehind-dist) 100) (set-motors! 0.8 0.8)]))
(run global-world on-tick)
                             