#lang racket
(require "../../basicWorldVisualization.rkt")
(require "../../baseWorldLogic.rkt")
(require "../../robotVisualization.rkt")
(require "../../helpers/canvas-edges.rkt")
(require "../../helpers/edge-helpers.rkt")
(require (prefix-in G-"../../geo/geo.rkt"))
(require (prefix-in R-"../../robot.rkt"))
(require 2htdp/image)
(provide
 run make-robot set-world!
 get-#robot get-#shoot-robot get-all-edges
 set-motors! shoot angle-to-other-bot
 set-radian-mode set-degree-mode normalize-angle)

(struct world:shoot (canvas edges robot1 robot2 [balls #:mutable]))
(struct ball (id pos vx vy type) #:mutable #:transparent)
(struct shoot-robot (robot on-tick lives balls-left ball-capacity last-fire) #:mutable)
(define global-world (void))
(define (get-world) global-world)
(define (get-shoot-robot-1) (world:shoot-robot1 (get-world)))
(define (get-shoot-robot-2) (world:shoot-robot2 (get-world)))
(define (get-#shoot-robot n) (if (= n 1) (get-shoot-robot-1) (get-shoot-robot-2)))
(define (get-#robot n) (shoot-robot-robot (get-#shoot-robot n)))
(define robot#-on 0) ;; this is highly jenk, but fuck it
(define (get-robot) (get-#robot robot#-on))
(define (get-shoot-robot) (get-#shoot-robot robot#-on))
(define (get-other-robot)
  (if (equal? (get-#robot 1) (get-robot)) (get-#robot 2) (get-#robot 1)))

(define global-ball-id -1)
(define (get-ball-id)
  (set! global-ball-id (+ global-ball-id 1))
  global-ball-id)

(define tick# 0)
(define DEFAULT_BODY_COLOR "grey")
(define DEFAULT_WHEEL_COLOR "black")
(define WORLD_WIDTH 450)
(define WORLD_HEIGHT WORLD_WIDTH)
(define MAX_NUM_BALLS 5)
(define num-balls MAX_NUM_BALLS)
(define BALL_RADIUS 10)
(define GLOBAL_MAX_VX 50)
(define GLOBAL_MAX_VY GLOBAL_MAX_VX)
(define max-vx 50)
(define max-vy max-vx)
(define SECS_PER_TURN 5)
(define BALL_IMAGE_NEUT (circle BALL_RADIUS "solid" "black"))
(define BALL_IMAGE_1 (circle BALL_RADIUS "solid" "red"))
(define BALL_IMAGE_2 (circle BALL_RADIUS "solid" "green"))
(define disqualified? #f)
(define STARTING_BALLS 5)
(define BALL_CAPACITY 4)
(define STARTING_LIVES 3)
(define angle-mode 'degrees)
(define cooldown 40)

(define (set-degree-mode) (set! angle-mode 'degrees))
(define (set-radian-mode) (set! angle-mode 'radians))

(define (make-robot name on-tick
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
  (define bot (simple-bot robot-image))
  ;(R-set-robot-angle! bot (/ pi 2))
  (shoot-robot bot on-tick STARTING_LIVES STARTING_BALLS BALL_CAPACITY (- 0 cooldown)))

(define START_WIDTH .75)
(define START_HEIGHT .75)
(define (set-world! shoot-bot1 shoot-bot2)
  (cond
    [(equal? shoot-bot1 shoot-bot2)
     "Jacob... what do you think you're doing???????????"]
    [else
     (R-set-pos! (shoot-robot-robot shoot-bot1) (* -1/2 START_WIDTH WORLD_WIDTH) (* -1/2 START_HEIGHT WORLD_HEIGHT))
     (R-set-pos! (shoot-robot-robot shoot-bot2) (*  1/2 START_WIDTH WORLD_WIDTH) (*  1/2 START_HEIGHT WORLD_HEIGHT))
     (R-set-robot-angle! (shoot-robot-robot shoot-bot2) pi)
     (set!
      global-world
      (world:shoot
       (create-blank-canvas WORLD_WIDTH WORLD_HEIGHT)
       (get-edges WORLD_WIDTH WORLD_HEIGHT)
       shoot-bot1 shoot-bot2
       (list)))]))

(define (ball-edges ball)
  (get-edges (* BALL_RADIUS 2) (* BALL_RADIUS 2) #:shift-by (ball-pos ball)))
(define (update-ball-pos ball)
  (set-ball-pos!
   ball
   (G-add-points
    (ball-pos ball)
    (G-scale-point TICK_LENGTH (G-point (ball-vx ball) (ball-vy ball))))))
(define ball-k 0.01)
(define neutrelize-chance .005)
(define (update-ball ball)
  (update-ball-pos ball)
  (cond
    [(< (random) neutrelize-chance) (set-ball-type! ball 'neut)])
  (cond 
    [(maps-intersect? (ball-edges ball) (get-all-edges #:excluded-ball-types (list 'neut 1 2)))
     (set-ball-vx! ball (* -1 (ball-vx ball)))
     (set-ball-vy! ball (* -1 (ball-vy ball)))
     ;(update-ball-pos ball)
     ]
    [else
     (set-ball-vx! ball (* (ball-vx ball) (- 1 ball-k)))
     (set-ball-vy! ball (* (ball-vy ball) (- 1 ball-k)))])
  (cond
    [(and (number? (ball-type ball))
          (maps-intersect? (robot-edges (get-#robot (- 3 (ball-type ball))))
                           (ball-edges ball)))
     (define bot (get-#shoot-robot (- 3 (ball-type ball))))
     (set-shoot-robot-lives! bot (- (shoot-robot-lives bot) 1))
     (remove-ball (ball-id ball))
     ]
    [(symbol? (ball-type ball))
     (define intersect-1? (maps-intersect? (robot-edges (get-#robot 1)) (ball-edges ball)))
     (define intersect-2? (maps-intersect? (robot-edges (get-#robot 2)) (ball-edges ball)))
     (cond
       [(or intersect-1? intersect-2?)
        (define robot (get-#shoot-robot (if intersect-1? 1 2)))
        (set-shoot-robot-balls-left!
         robot
         (+ (shoot-robot-balls-left robot) 1))
        (remove-ball (ball-id ball))])]))


(define (get-all-edges #:excluded-ball-types [excluded-ball-types (list)]
                       #:robot-edges-1? [robot-edges-1? #f]
                       #:robot-edges-2? [robot-edges-2? #f])
  (define all-balls
    (filter
     (lambda (ball) (not (memv (ball-type ball) excluded-ball-types)))
     (world:shoot-balls global-world)))
  (define all-ball-edges (foldl append (list) (map ball-edges all-balls)))
  (define bot1-edges (if robot-edges-1? (robot-edges (get-#robot 1)) (list)))
  (define bot2-edges (if robot-edges-2? (robot-edges (get-#robot 2)) (list)))
  (append all-ball-edges bot1-edges bot2-edges (world:shoot-edges global-world)))

(define (remove-ball r-ball-id)
  (set-world:shoot-balls!
   (get-world)
   (filter (lambda (ball) (not (= (ball-id ball) r-ball-id)))
           (world:shoot-balls (get-world)))))

(define (overlay-ball ball canvas)
  (overlay-image
   canvas
   (match (ball-type ball)
     [1 BALL_IMAGE_1]
     [2 BALL_IMAGE_2]
     ['neut BALL_IMAGE_NEUT])
   0 (ball-pos ball)))

(define force-fac 1.3)
(define (set-motors! left% right%)
  (R-set-inputs! (get-robot) (* left% force-fac) (* right% force-fac) #:max force-fac))
(define ball-vi 5)
(define (double-randomized n) (random (- 0 n) n))
(define (get-cooldown-timer)
  (- (+ cooldown (shoot-robot-last-fire (get-shoot-robot))) tick#))
(define (add-random-ball)
  (define pos (G-point (double-randomized (- (/ WORLD_WIDTH  2) BALL_RADIUS))
                       (double-randomized (- (/ WORLD_HEIGHT 2) BALL_RADIUS))))
  (define type 'neut)
  (define shot-ball (ball (get-ball-id) pos 0 0 type))
  (add-ball shot-ball))
(define (shoot)
  (cond
    [(and
      (> (shoot-robot-balls-left (get-shoot-robot)) 0)
      (> (- tick# (shoot-robot-last-fire (get-shoot-robot))) cooldown))
     (set-shoot-robot-balls-left!
      (get-shoot-robot)
      (- (shoot-robot-balls-left (get-shoot-robot)) 1))
     (set-shoot-robot-last-fire! (get-shoot-robot) tick#)
     (define angle (R-robot-angle (get-robot)))
     (define r-pos (G-point (R-robot-x (get-robot)) (R-robot-y (get-robot))))
     (define type (if (equal? (get-robot) (get-#robot 1)) 1 2))
     (define robot-v (/ (+ (R-robot-vl (get-robot)) (R-robot-vr (get-robot))) 2))
     (define omega (/ (- (R-robot-vr (get-robot)) (R-robot-vl (get-robot)))
                      (R-robot-width (get-robot))))
     (define perp-v (* omega (R-robot-length (get-robot)) 0.5))
     (define pos
       (G-add-points r-pos
                     (G-rotate-point (G-point (* .5 (R-robot-length (get-robot))) 0) angle)))
     (define shot-ball (ball (get-ball-id) pos
                             (+ (* (+ ball-vi robot-v) (cos angle)) (* perp-v (sin angle)))
                             (+ (* (+ ball-vi robot-v) (sin angle)) (* perp-v (cos angle)))
                             type))
     (add-ball shot-ball)]))
(define (add-ball ball)
  (set-world:shoot-balls!
      (get-world)
      (cons ball (world:shoot-balls (get-world)))))
(define (angle-to-other-bot)
  (define radians-angle
    (-
     (G-angle-between
       (R-robot-point (get-robot)) (R-robot-point (get-other-robot)))
     (R-robot-angle (get-robot))))
  (normalize-angle
   (if (equal? angle-mode 'radians) radians-angle (radians->degrees radians-angle))))

(define (normalize-angle angle)
  (if (equal? angle-mode 'radians)
      (G-normalize-angle:rad angle)
      (G-normalize-angle:deg angle)))

(define ticks-per-new-ball 500)
(create-run-function
 internal-run
 [(set! tick# 0)
  (define (edges-1)
    (get-all-edges #:excluded-ball-types (list 'neut 1 2) #:robot-edges-2? #t))
  (define (edges-2)
    (get-all-edges #:excluded-ball-types (list 'neut 1 2) #:robot-edges-1? #t))
  (define walls
    (get-all-edges #:excluded-ball-types (list 'neut 1 2)))]
 (lambda (world)
   (cond
     [(= (random ticks-per-new-ball) 0) (add-random-ball)])
   (move-bot (get-#robot 1) 1 #:edges (edges-1))
   (move-bot (get-#robot 2) 1 #:edges (edges-2))
   (map update-ball (world:shoot-balls (get-world)))
   (set! robot#-on 1)
   ((shoot-robot-on-tick (world:shoot-robot1 (get-world))) tick#)
   (set! robot#-on 2)
   ((shoot-robot-on-tick (world:shoot-robot2 (get-world))) tick#)
   (set! tick# (+ tick# 1))
   (overlay-robot
    (overlay-robot
     (foldl
      overlay-ball
      (world:shoot-canvas world)
      (world:shoot-balls world))
     (get-#robot 1))
    (get-#robot 2)))
 get-world
 [] []
 (lambda (world)
   (or (= (shoot-robot-lives (get-#shoot-robot 1)) 0)
       (= (shoot-robot-lives (get-#shoot-robot 2)) 0)))
 [(cond
    [(= (shoot-robot-lives (get-#shoot-robot 1)) 0) (printf "player 2 wins")]
    [(= (shoot-robot-lives (get-#shoot-robot 2)) 0) (printf "player 1 wins")]
    [else (printf "tfw ur lame :(")])])
(define-syntax-rule (run) (internal-run (lambda (_) (void))))