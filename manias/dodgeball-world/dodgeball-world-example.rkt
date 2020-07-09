#lang racket
;; COPY THIS CODE INTO ANOTHER FILE IF YOU ARE USING GITHUB
;; COPY THIS CODE INTO ANOTHER FILE IF YOU ARE USING GITHUB
;; COPY THIS CODE INTO ANOTHER FILE IF YOU ARE USING GITHUB
(require "../../lib/worlds/dodgeball-world/example-bots/example-bots.rkt")

;; Welcome to the dodgeball world! The first ever VRC 1 vs 1 competiton

;; Here you will be tasked with creating a robot that can shoot balls at
;;   your opponent-- better than your opponent can shoot them at you!

;; Every time you get hit your robot will fade away just a bit. Last robot
;;   standing wins!

(require "../../lib/worlds/dodgeball-world/dodgeball-world.rkt")
;(require "../../lib/worlds/dodgeball-world/dodgeball-world-advanced.rkt")
;(require "../../lib/worlds/dodgeball-world/dodgeball-world-expert.rkt")
; Above you can choose either the regular, advanced or expert chase-world.
;   All of these worlds have the exact same functions. For more
;   info on the differneces, run the function (level-diffs)


; QUICKSTART

; for a more detailed explanation, go to the following link:
;    https://github.com/zevbo/VirtualRobotMania/tree/master/manias/dodgeball-world

; Past functions:
; Motors:
;   (set-motors! n1 n2), (change-motor-inputs n1 n2), (get-left%), (get-right%)
; Sensors:
;   (get-looking-dist angle), (get-robot-angle),  (get-vl), (get-vr)
;   (get-lookahead-dist angle), (get-lookbehind-dist angle)       
; Utilities:
;   (normalize-angle angle)

; New functions
; (shoot) -> shoots a ball forward
; (angles-to-neutral-balls) -> returns a list of the angles to all the neutral balls (neutral balls = balls you can pick up)
; (get-cooldown-time) -> returns how many ticks until you can shoot again. 0 if you can shoot now
; (num-balls-left) -> returns the number of balls you have left
; (front-left-close?), (front-right-close?), (back-left-close?), (back-right-close?) -> 
;      tells you if any given corner is very close (within 15) of a wall 
; (angle-to-other-bot), (relative-angle-of-other-bot), (dist-to-other-bot), (other-bot-shooting?), (other-bot-level)
; (set-degree-mode), (set-radian-mode)

(define (on-tick tick#)
  (set-degree-mode) ;; make sure to have this line in on-tick
  (cond
    [(or (front-left-close?) (front-right-close?)) (set-motors! -1 -1)]
    [else (set-motors! 0.8 1)]
    )
  )

(define your-bot
  (make-robot
   "A Robot" on-tick
   #:body-color "blue"
   #:wheel-color "black"
   #:image-url "https://i.pinimg.com/originals/02/0d/08/020d08c863f0742e40a11585c26f2f21.png"
   #:name-color "black"
   ))
  
; Starting the game:
; In this game, the set-world! function takes two robots, instead of just one
; One of the two robots should by your robot, but the other should be
;   a different robot.
; By default this file pits you up against "bot-boi," but we provide
;   four robots for you to choose from. Here are their decriptions:
; staionary-bot, Level 0: Does absolutely nothing
; bot-boi, Level 1: Bot boi is a little timid, and not great at picking
;   up neutral balls. But if you give him too much time, he will take a
;   good straight shot
; the-dagger, Level 2: The dagger specializes in close range attacks. It
;   has a great ability to run around your robot and hit it from the side
;   or back. However, despite its patience, it can get confused easily.
; eager-shooter, Level 3: The opposite of the dagger, the eager shooter
;   specializes in getting rid of its balls as quickly as possible, and
;   then picking up some more. But if your fast enough, and accurate enough
;   you can make it's quick firing and subsuquent loss of balls seem naive
; pelosi-mobeel, Level 4: Cunning and effective. That's the Pelosi-Mobeel for
;   you. It has the best shot, easily pinning apponents with darting long
;   range shots. It has one weakness though: unlike the real Pelosi it has
;   no ability to purposefuly pick up more balls.

(set-world! your-bot bot-boi)
(run)