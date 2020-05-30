#lang racket
(require "chase-world-base.rkt")
(require "../../geo/geo.rkt")
(require (prefix-in R-"../../robot.rkt"))
(provide make-robot set-world!
         run
         set-motors! change-motor-inputs
         get-left% get-right% get-robot-angle get-vl get-vr
         get-looking-dist get-lookahead-dist get-lookbehind-dist get-ball-hue get-ball-brightness
         num-balls MAX_NUM_BALLS ball-exists?
         $get-ball-vx$ $get-ball-vy$ angle-to-ball~
         help)
(set-world-width! (exact-floor (* world-width 1.2)))
(set-cut-offs! 15 30 90 180)
(define ($get-ball-vx$ ball#)
  (disqualify)
  (get-ball-vx ball#))
(define ($get-ball-vy$ ball#)
  (disqualify)
  (get-ball-vy ball#))
;dist (R-robot-point (get-robot)) (ball-pos (get-ball ball#)))
(define (angle-to-ball~ ball#)
  (if (or (is-ball-bouncing? ball#) (not (ball-exists? ball#)))
      (angle-to-ball ball#)
      #t))
(define (help)
  (printf "
;; Welcome to the chase world!
;; Your goal is to program your robot to hit all the balls as quickly as possible
;; Once you get all the balls, the program will print out how long it took

;; Need a refresher? There are tons of comments here:
;; https://github.com/zevbo/VirtualRobotMania/blob/master/manias/exampleManias/primo-world-example.rkt

;; IMPORTANT REFRESHERS
;; (get-looking-dist angle) or (get-looking-dist angle #:no-balls? #t) ->
;;     get's the distance from the center of the robot to the nearest obstacle in the direction of the given angle relative to the robot
;; EXAMPLE: (get-looking-dist 0 #:no-balls? #t) -> this will get the distance to a wall, instead of the nearest object
;;    You can also use this option with get-lookahead-dist and get-lookbehind-dist
;; (set-motors! num1 num2) and (change-motor-inputs num1 num2)

;; NEW STUFF
;; num-balls -> a variable that says the number of balls left
;; MAX_NUM_BALLS -> total balls in this round (including one's you've gotten)
;; (ball-exists? ball#) -> tells you if that ball exists/hasn't been gotten yet
;; (angle-to-ball~ ball#) -> takes a ball# (where ball# is an integer such that: 0 <= ball# < num-balls) and gives you the angle to that ball
;;     It will only give you the dist to the ball if the ball changed direction or speed that tick. Otherwise, it will give you #t
;;     If that ball# has already been gotten, it returns #f
;; (get-ball-hue ball#) and (get-ball-brightness ball#) -> get's the given ball's hue (color scale) or brightenss
;;     Why are these important? Well, long ago, the ancestors of the balls your are chasing colored themselves to communicate how they were moving
;;         in order to coordinate better to get away from any possible predators (such as you). Now luckily enough for you I came across that
;;         information years ago on a praticularly grueling quest to an undergroud library in the Virtual Oldtown Citadel. Unfortunately, I could
;;         not find and information on exactly how this communication was used. Good luck!
;; ($get-ball-vx$ ball#) and ($get-ball-vy$ ball#) -> these get the x or y velocity of a given ball. However, if you use them your score doesn't count
;;     You may use them for, let's say, experimental reasons :)
"))