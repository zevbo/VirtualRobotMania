# Dodgeball World

Welcome to the dodgeball world! The first ever VRC 1 vs 1 competiton

Here you will be tasked with creating a robot that can shoot balls at
your opponent -- better than your opponent can shoot them at you!

Every time you get hit your robot will fade away just a bit. Last
robot standing wins!

## Rules

As long as you aren't in your cooldown period (mode on that later) and
you have at least one ball left, you can shoot from the front of your
robot with the (shoot) function.

When you fire a ball it will come out as your color (red or green
depending on where you start). If you get hit by a ball of the other
players color, you will lose a life and become more transparent.

Every tick, there is some chance (depending on your level) that a ball
you just fired will become neutral, and turn black

If you hit a black (or neutral ball) and you have fewer balls than
your ball capacity, you will pick up that ball.

You are hit by a ball if the bounding box of your robot intersects the
bounding box of the ball. Note: if the ball is completely inside of
your robot, you can neither pick it up nor be hit by it, until it hits
the edge.

Remember how whenever you get hit you lose a life and become more
transparent? Well, when you become fully transparent, that means you
have no more lives left and the other robot wins

Last note: you will start either in the bottom left or top right
(there is a little randomness in the starting y position)

## Past functions

You should remember most of these from previous manias!

- `(set-motors! n1 n2)` sets the force being put into each side of the
  robot. 1 is the max, and -1 is the min for each side
- `(change-motor-inputs n1 n2)` changes the force being put into each
  of the robot by the give amount for example: if before the motors
  were set to `(0.6, 0.3)`, and you call `(change-motor-inputs -0.1
  0.4)`, the motors will become set to `(0.5, 0.7)`

; (get-looking-dist angle) -> sees how far you can look in the direction of the given angle until there is an object,
;    which could be a ball, wall or another robot. It is measured from the center of the robot, 0 is looking directly
;    forward, and positive angles are towards the left.

; (get-lookahead-dist), (get-lookbehind-dist) -> the same as get-looking-dist except they are measured
;    from the front and back of the robot respectively, and obviously the angles are always 0 and 180 degrees respectively

; (get-left%), (get-right%) -> gets the input (ie: force) to the left or right motors

; (get-robot-angle) -> get's the global angle (ie what angle the robot is drawn at) of the robot. Again, turning leftwards is positive
;    The robot starts at an angle of 0.
;    The magnitude of this angle can be larger than 180. For instance, if you make one rull rotation, (get-robot-angle) will return 360

; (normalize-angle angle) -> takes an angle outside of the range [-180, 180) and returns the coresponding angle in that range

; (get-vl), (get-vr) -> get's the speed (in pixels per tick) of the left and right wheel of your robot

; New functions
; Note: any specs that depend on your level can be found by runnning (level-diffs)
; (shoot) -> shoots a ball forward. The speed is effected by the speed of your robot
; (angles-to-neutral-balls) -> returns a list of the angles to all the neutral balls (neutral balls = balls you can pick up)
;    if a ball is straight ahead, it will say 0.
; (get-cooldown-time) -> returns how many ticks until you can shoot again. 0 if you can shoot now
;    [run (level-diffs) to see average cooldown periods]
; (num-balls-left) -> returns the number of balls you have left
; (front-left-close?), (front-right-close?), (back-left-close?), (back-right-close?) ->
;    tells you if any given corner is very close (within 15) of a wall
; (angle-to-other-bot) -> returns the angle to the other bot. Leftwards is positive. If you are facing the other robot, this
;    function will return 0. If it is directly behind you, it will return -180. If you would have to turn a little left to be
;    facing it the number would be a small positive. Another way to think about what this function does, is say how much left
;    you have to turn to be facing the other bot.
; (relative-angle-of-other-bot) -> tells you the relative angle of the other robot. So, if they are
;    coming directly twoards you, it is 180 or -180. Precisely, it is their angle - your angle.
; (dist-to-other-bot) -> returns the distance in pixels to the other robot
; (other-bot-shooting?) -> tells you if the other bot shot last tick
; (other-bot-level) -> returns the level of the other robot. Possible values are: 'normal, 'advanced and 'expert
; (set-degree-mode), (set-radian-mode) -> makes it so that all of your angles (both that you give to
;    get from functions) are in the mode that you choose. Make sure to write this in on-tick.
;    a quick referesher: in degrees angle go from 0 to 360. Radians go from 0 to 2π
