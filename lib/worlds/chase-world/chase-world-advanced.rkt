#lang racket
(require "chase-world-base.rkt")
(require "../../geo/geo.rkt")
(require (prefix-in R-"../../robot.rkt"))
(provide make-robot set-world!
         run
         set-motors! change-motor-inputs
         get-left% get-right% get-robot-angle get-vl get-vr
         get-looking-dist get-lookahead-dist get-lookbehind-dist
         num-balls
         get-ball-vx get-ball-vy
         help)
(set-world-width! (exact-floor (* world-width 1.2)))
;dist (R-robot-point (get-robot)) (ball-pos (get-ball ball#)))
(define (angle-to-ball~ ball#)
  (if (is-ball-bouncing? ball#)
      (angle-to-ball ball#)
      #f))
(define (help)
  (printf "
;; Welcome to the chase world!
;; Your goal is to program your robot to hit all the balls as quickly as possible
;; Once you get all the balls, the program will print out how long it took

;; Need a refresher? There are tons of comments here:
;; https://github.com/zevbo/VirtualRobotMania/blob/master/manias/primo-world-example.rkt

;; IMPORTANT REFRESHERS
;; (get-looking-dist angle) -> get's the distance from the center of the robot to the nearest obstacle in the direction of the given angle relative to the robot
;; (set-motors! num1 num2) and (change-motor-inputs num1 num2)

;; NEW STUFF
;; num-balls -> a variable that says the number of balls left
;; (angle-to-ball~ ball#) -> takes a ball# (where ball# is an integer such that: 0 <= ball# < num-balls) and gives you the angle to that ball
;;     It will only give you the angle to the ball if the ball changed direction or speed that tick. Otherwise, it will give you false
;; (get-ball-vy ball#) and (get-ball-vx ball#) -> get's the given ball's y or x speed per tick
"))