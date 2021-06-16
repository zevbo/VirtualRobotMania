#lang scribble/manual

@title{Algorithims}

Most of the algorithims you will need to complete an awesome virtual robot can be classified into one of two groups

@itemlist[
    @item{Controllers - a controller is an algorithim that given some input or the state of the game, makes a desicion about what the robot should do.
    For instance, in capture the flag, a controller for the offense robot might take as an input the angle to the flag, and output how much the motors should turn.
    A controller for the offense bot might take into account where the offense robot is, and decide whether or not to shoot.}
    @item{Predictors - a predictor (not a formal robotics term) is an algorithim that guesses what will happen in the fututre.
    The CTF defense bot might for instance want to guess where the offense bot will be in some amount of time, so that it can better decide whether or not to shoot.}
]

This page will largely focus on controllers, as effectivelly everyone needs them.
But if you want to take your robot to the next level though, we definitely suggest creating some predictors!
If you don't know where to start, see our @link["predictors.html"]{quick discussion on predictors}.

@section{Boolean Controllers}

Boolean controllers refers to any controller that outputs whether or not to perform some action (say shoot a laser, or use a boost).

@section{Bang-Bang Controllers}

A bang-bang controller is one that makes desicions through a series of conditionals.
You are actaully very used to bang-bang controllers in your every day life.
For instance your air conditioning will cool the apartment if the temperature is above the desired one, and do nothing otherwise.
Similarly, let's consider the following bang bang contorller for a virtual robot that wanted to go 15 degrees north of east (ie: with angle 15).

@racket[
    (define (go-right)
      (degrees-mode)
      (cond 
        [(> (get-robot-angle) 15) (set-motors 1 0.8)]
        [else (set-motors 0.8 1)]))
]

If you're curious, try adding this function to a robot, call it from on-tick, and see what it does!

Unfortunately, there's a pretty big issue with this approach.

