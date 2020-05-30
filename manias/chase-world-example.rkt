#lang racket
(require "../lib/worlds/chase-world/chase-world.rkt")
;; instead of chase-world.rkt, you can do chase-world-advanced.rkt or chase-world-expert.rkt
;; Skipping to advanced is reasonable, but I think one should do advanced before
;;    doing expert
;; If you are doing one of those, use the (help) function to see what's different

;; Welcome to the chase world!
;; Your goal is to program your robot to hit all the balls as quickly as possible
;; Once you get all the balls, the program will print out how long it took
;; Note: most functions will return #f if you try to retrieve infromation from a
;;    ball# that you have already captured

;; Need a refresher? There are tons of comments here:
;; https://github.com/zevbo/VirtualRobotMania/blob/master/manias/primo-world-example.rkt

;; IMPORTANT REFRESHERS
;; (get-looking-dist angle) or (get-looking-dist angle #:no-balls? #t) ->
;;     get's the distance from the center of the robot to the nearest obstacle in the direction of the given angle relative to the robot
;; EXAMPLE: (get-looking-dist 0 #:no-balls? #t) -> this will get the distance to a wall, instead of the nearest object
;;    You can also use this option with get-lookahead-dist and get-lookbehind-dist
;; (set-motors! num1 num2) and (change-motor-inputs num1 num2)

;; NEW STUFF
;; num-balls -> a variable that says the number of balls left
;; MAX_NUM_BALLS -> total balls in this round (including one's you've gotten)
;; (angle-to-ball ball#) -> takes a ball# (where ball# is an integer such that: 0 <= ball# < num-balls) and gives you the angle to that ball
;;     if that ball# has already been gotten, it returns #f
;; (get-ball-vy ball#) and (get-ball-vx ball#) -> get's the given ball's y or x speed per tick
;; (help) -> basically prints out everything above this

(define my-bot
  (make-robot
   "Pelosi Mo-beel"
   #:body-color "pink"
   #:wheel-color "green"
   #:image-url "https://pyxis.nymag.com/v1/imgs/dea/e96/43d78070c0f7cff46d506c303850980bb0-nancy-pelosi.rsquare.w700.jpg"
   ))


(define (on-tick tick#)
  (cond
    [(= tick# 0) (set-motors! 1 1)])
  
  )

(set-world! my-bot)
(void (run on-tick))