#lang racket
(require "../basicWorldVisualization.rkt")
(require "../baseWorldLogic.rkt")
(require "../robotVisualization.rkt")
(require "../helpers/canvas-edges.rkt")
(require "../helpers/edge-helpers.rkt")
(require (prefix-in G-"../geo/geo.rkt"))
(require (prefix-in R- "../robot.rkt"))
(require 2htdp/image)
(provide make-robot set-world!
         run
         set-motors! change-motor-inputs
         get-left% get-right% get-robot-angle get-vl get-vr
         get-looking-dist get-lookahead-dist get-lookbehind-dist angle-to-ball
         num-balls)

(define-syntax-rule (mutable-struct name (vars ...) keywords ...)
  (struct name ([vars #:mutable] ...) keywords ...))
(struct world:dodge (canvas edges robot balls))
(define global-ball-id 0)
(define (get-ball-id)
  (set! global-ball-id (+ global-ball-id 1))
  (- global-ball-id 1))
(mutable-struct ball (id pos vx vy hue hit?) #:transparent)
(define global-world (void))
(define (get-world) global-world)
(define (get-robot)
  (world:dodge-robot global-world))

(define (get-balls-left)
  (filter (lambda (ball) (not (ball-hit? ball))) (world:dodge-balls global-world)))

(define DEFAULT_BODY_COLOR "grey")
(define DEFAULT_WHEEL_COLOR "black")
(define WORLD_WIDTH 350)
(define WORLD_HEIGHT WORLD_WIDTH)
(define MAX_NUM_BALLS 5)
(define num-balls MAX_NUM_BALLS)
(define BALL_RADIUS 10)
(define max_vx 30)
(define max_vy max_vx)
(define SECS_PER_TURN 5)
(define BALL_IMAGE (circle BALL_RADIUS "solid" "black"))

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
  (set! num-balls MAX_NUM_BALLS)
  (set!
   global-world
   (world:dodge
    (create-blank-canvas WORLD_WIDTH WORLD_HEIGHT)
    (get-edges WORLD_WIDTH WORLD_HEIGHT)
    robot
    (starting-balls))))

(define BALL_S 0.8)
(define BALL_V 0.8)
(define (random-hue) (random 360))
(define (to-rgb h s v)
  (define c (* v s))
  (define x (* c (- 1 (abs (- (modulo (floor (/ h 60)) 2) 1)))))
  (define m (- v c))
  (define-values (R G B)
    (match (floor (/ h 60))
      [0 (values c x 0)]
      [1 (values x c 0)]
      [2 (values 0 c x)]
      [3 (values 0 x c)]
      [4 (values x 0 c)]
      [5 (values c 0 x)]))
  (define (prime->reg v) (inexact->exact (floor (* (+ v m) 255))))
  (values (prime->reg R) (prime->reg G) (prime->reg B)))
(define (ball-image ball)
  (define-values (r g b) (to-rgb (ball-hue ball) BALL_S BALL_V))
  (circle BALL_RADIUS "solid" (make-color r g b))
  ;BALL_IMAGE
  )

(define (double-randomized n) (random (- 0 n) n))
(define (random-ball)
  (define randomize-x? (= (random 2) 0))
  (define randomize-y? (not randomize-x?))
  (define (determine-coord randomize? total-space)
    (if randomize?
        (double-randomized (/ (- total-space (* BALL_RADIUS 2)) 2))
        (* (- (random 2) 0.5) total-space 0.8)))
  (ball (get-ball-id)
        (G-point (determine-coord randomize-x? WORLD_WIDTH)
                 (determine-coord randomize-y? WORLD_HEIGHT))
        (double-randomized max_vx)
        (double-randomized max_vy)
        (random-hue) #f))
(define (starting-balls)
  (define (populator current-balls balls-left)
    (define new-ball (random-ball))
    (cond
      [(= balls-left 0) current-balls]
      [(ormap (lambda (ball) (maps-intersect? (ball-edges new-ball) (ball-edges ball))) current-balls)
        (populator current-balls balls-left)]
      [else (populator (cons new-ball current-balls) (- balls-left 1))]))
  (populator (list) num-balls)
  )
(define (ball-edges ball)
  (get-edges (* BALL_RADIUS 2) (* BALL_RADIUS 2) #:shift-by (ball-pos ball)))
(define (update-ball-pos ball)
  (set-ball-pos! ball
                 (G-add-points (ball-pos ball)
                               (G-scale-point TICK_LENGTH (G-point (ball-vx ball) (ball-vy ball))))))
(define (update-ball ball)
  (update-ball-pos ball)
  (cond
    [(maps-intersect? (ball-edges ball) (robot-edges (get-robot)))
     (set-ball-hit?! ball #t)
     (set! num-balls (- num-balls 1))]
    [(maps-intersect? (ball-edges ball) (get-all-edges  #:excluded-balls (list ball)))
     (set-ball-vx! ball (* -1 (ball-vx ball)))
     (set-ball-vy! ball (* -1 (ball-vy ball)))
     (update-ball-pos ball)]
    [(= (random (* SECS_PER_TURN TICKS_PER_SECOND)) 0)
     (set-ball-vx! ball (double-randomized max_vx))
     (set-ball-vy! ball (double-randomized max_vy))
     (set-ball-hue! ball (random-hue))
     (set! max_vx (+ max_vx 1))
     (set! max_vy (+ max_vy 1))]))

(define (get-all-edges #:excluded-balls [excluded-balls (list)] #:robot-edges? [robot-edges? #f])
  (define all-balls
    (filter
     (lambda (ball) (and (not (ball-hit? ball)) (not (memv (ball-id ball) (map ball-id excluded-balls)))))
     (world:dodge-balls global-world)))
  (define all-ball-edges (foldl append (list) (map ball-edges all-balls)))
  (define bot-edges (if robot-edges? (robot-edges (get-robot)) (list)))
  (append all-ball-edges bot-edges (world:dodge-edges global-world)))
(define (get-looking-dist angle)
  (define edges (get-all-edges))
  (get-robot-map-dist edges (get-robot) (degrees->radians angle))
  )
(define (get-lookahead-dist)  (- (get-looking-dist 0)   (/ ROBOT_LENGTH 2)))
(define (get-lookbehind-dist) (- (get-looking-dist 180) (/ ROBOT_LENGTH 2)))
(define (get-ball ball# balls)
  (list-ref (filter (lambda (ball) (not (ball-hit? ball))) balls) ball#))
(define (angle-to-ball ball#)
  (cond
    [(not (integer? ball#))
     (raise (format "Attempted to get angle to ball# ~s, but ~s is not an integer" ball# ball#))]
    [(or (< ball# 0) (>= ball# num-balls))
     (raise (format "Attempted to get angle to ball# ~s, but ~s is must be between 0 and ~s" ball# ball# num-balls))]
    [else
     (define ball (get-ball ball# (world:dodge-balls global-world)))
     (radians->degrees (- (G-angle-between (R-robot-point (get-robot)) (ball-pos ball))
                          (robot-angle (get-robot))))]))

(define (overlay-ball ball canvas)
  (if (ball-hit? ball)
      canvas
      (overlay-image
       canvas (ball-image ball) 0 (ball-pos ball))))
(define (all-balls-gone? . _)
  (empty? (get-balls-left)))
(define starting-time 0)
(create-run-function
 run
 [(define outer-edges (get-all-edges #:excluded-balls (world:dodge-balls global-world)))
  (set! starting-time (current-milliseconds))]
 (lambda (world)
   (move-bot (world:dodge-robot world) 0.75 #:edges outer-edges)
   (map update-ball (get-balls-left))
   (foldl
    overlay-ball
    (overlay-robot
     (world:dodge-canvas world)
     (world:dodge-robot world))
    (world:dodge-balls world)))
 get-world
 [] []
 all-balls-gone?
 [(cond
    [(all-balls-gone?)
     (define time (exact-floor (/ (- (current-milliseconds) starting-time) 1000)))
     (define minutes (exact-floor (/ time 60)))
     (define seconds (- time (* minutes 60)))
     (printf
      (string-append
       (cond [(< time 15) "Unbelievable!!"] [(< time 30) "Wow."] [(< time 60) "Well done."]
             [(< time 120) "Could be better, could be worse."] [else "At least you finished, but there's definitely some room for improvement"])
       " You got all the balls in" (if (> minutes 0) (format " ~s minutes and " minutes) "") (format " ~s seconds~n~n" seconds)))
     (printf "FINAL SCORE: ~s:~s" minutes (if (< seconds 10) (format "0~s" seconds) seconds))]
    [else
     (printf "Awwwwww. You couldn't get all of the balls :(")])])

(define (set-motors! left% right%)
  (R-set-inputs! (get-robot) left% right%))
(define (get-left%)  (R-robot-left%  (get-robot)))
(define (get-right%) (R-robot-right% (get-robot)))
(define (get-vl) (R-robot-vl (get-robot)))
(define (get-vr) (R-robot-vr (get-robot)))
(define (change-motor-inputs Δleft% Δright%)
  (set-motors! (+ (get-left%) Δleft%) (+ (get-right%) Δright%)))
(define (get-robot-angle)
  (R-robot-angle (get-robot)))
