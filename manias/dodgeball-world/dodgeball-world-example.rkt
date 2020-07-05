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
;(require "../../lib/worlds/dodgeball-world/dodgeball--advanced.rkt")
; Above you can choose either the regular or advanced chase-world. Both of these worlds have
;   the exact smame functions. For more info on the differneces, run the function (level-diffs)

; QUICK RULES/EXPLANATIONS
#|
|#
; Past functions:
; (set-motors! n1 n2), (change-motor-inputs n1 n2), (get-looking-dist angle), (get-lookahead-dist angle), (get-lookbehind-dist angle)
; (get-left%), (get-right%), (get-robot-angle), (get-vl), (get-vr), (normalize-angle angle)

; New functions
; (shoot) -> shoots a ball forward
; (angles-to-neutral-balls) -> returns a list of the angles to all the neutral balls (neutral balls = balls you can pick up)
; (get-cooldown-time) -> returns how many ticks until you can shoot again. 0 if you can shoot now
; (num-balls-left) -> returns the number of balls you have left
; (front-left-close?), (front-right-close?), (back-left-close?), (back-right-close?) -> 
;      tells you if any given corner is very close (within 15) of a wall 
; (angle-to-other-bot), (relative-angle-of-other-bot), (dist-to-other-bot), (other-bot-shooting?), (other-bot-level)
; (set-degree-mode), (set-radian-mode)

; for a more detailed explanation, write (detailed-explanation) or uncomment the third to last line
(define (on-tick tick#)
  (set-radian-mode) ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (cond
    [(or (front-left-close?) (front-right-close?)) (set-motors! -1 -1)]
    [else (set-motors! 0.8 1)]
    )
  )

(define my-bot
  (make-robot
   "A Robot" on-tick
   #:body-color "blue"
   #:wheel-color "black"
   #:image-url "https://i.pinimg.com/originals/02/0d/08/020d08c863f0742e40a11585c26f2f21.png"
   #:name-color "black"
   ))
  

; (detailed-explanation)
(set-world! my-bot bot-boi)
(run)