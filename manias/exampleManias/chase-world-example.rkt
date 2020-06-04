#lang racket

;; Welcome to the chase world!
;;
;; Your goal is to program your robot to hit all the balls as quickly as possible
;; Once you get all the balls, the program will print out how long it took
;;
;; First, pick which version you want to do.  This file starts out in beginner mode,
;; but you can pick "advanced" or "expert" by commenting out the first require statement
;; below, and uncommenting one of the others.

(require "../../lib/worlds/chase-world/chase-world.rkt")
;(require "../../lib/worlds/chase-world/chase-world-advanced.rkt")
;(require "../../lib/worlds/chase-world/chase-world-expert.rkt")

;; Skipping to advanced is reasonable, but you should try advanced before
;; export.
;;
;; If you are doing one of those, run (help) to see what's different!

;; Note: most functions will return #f if you try to retrieve infromation from a
;;    ball# that you have already captured
;; Need a refresher? There are tons of comments here:
;;
;; https://github.com/zevbo/VirtualRobotMania/blob/master/manias/exampleManias/primo-world-example.rkt

;; IMPORTANT REFRESHERS
;; (get-looking-dist angle)
;;     get's the distance from the center of the robot to the nearest 
;;     obstacle in the direction of the given angle relative to the robot
;; (set-motors! num1 num2)
;;     Sets the speed of the left and right motor respectively.  i.e.,
;;     (set-motors 0.5 0.5) sets you going at half speed, straight ahead.
;;     (set-motors -1 1) sets you turning to the left as fast as you can.
;;     Speeds are effectively clamped outside of [-1,1], so numbers beyond
;;     1 and -1 behave just like 1 and -1.
;; (change-motor-inputs num1 num2)
;;     Adjusts the speed of the motors.  So,
;;      (set-motors! 0 0.1) followed by (change-motor-inputs 0.5 -0.5) is
;;      the same as (set-motors! 0.5 -0.4)

;; NEW STUFF
;; (get-looking-dist angle #:no-balls? bool)
;;     Lets you measure the distance in a way that will look through the balls.
;;     EXAMPLE: 
;;         (get-looking-dist 0 #:no-balls? #t)
;;         this will get the distance to a wall, instead of the nearest object
;;     You can also use this option with get-lookahead-dist and get-lookbehind-dist
;; num-balls
;;     variable that says the number of balls left
;; MAX_NUM_BALLS
;;     total balls in this round (including one's you've gotten)
;; (angle-to-ball ball#)
;;     takes a ball#, an integer such that 0 <= ball# < num-balls 
;;     if that ball# is still there, it returns the angle to the ball
;;     if that ball# is gone, it returns #f
;; (angle-to-first-ball) -> calls angle-to-ball with the smallest ball# that exists. Returns #f if no balls are left
;; (get-ball-vy ball#) and (get-ball-vx ball#)
;;     get's the given ball's y or x speed per tick
;; (ball-exists? ball#) -> says if that ball hasn't been gotten yet
;; (normalize-angle angle) -> brings an angle to in between -180 and
;;   180
;; (help)
;;     basically prints out everything above this

(define my-bot
  (make-robot
   "Pelosi Mo-beel"
   #:body-color "pink"
   #:wheel-color "green"
   #:image-url "https://pyxis.nymag.com/v1/imgs/dea/e96/43d78070c0f7cff46d506c303850980bb0-nancy-pelosi.rsquare.w700.jpg"
   ))

(define (on-tick tick#)
  (cond
    [(= tick# 0) (set-motors! 1 1)]
    )
  
  )

(set-world! my-bot)
(void (run on-tick))