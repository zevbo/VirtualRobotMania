#lang scribble/manual
@defmodule[ctf]

@title{Capture the Flag!}


Welcome to a new Virtual Robotics competition! This year's competition
is a step up in the complexity of the tasks, but writing bots should
still be easy for beginners.

Everyone is going to work in teams of two, and those teams need to
make two different robots together:

@itemlist[
@item{An @bold{offense bot}, whose goal is to capture the flag, and bring it
  back to its home base.}

@item{A @bold{defense bot} whose goal is to stop the offense bot from
  getting the flag.}
]

The defense bot can stop the offense bot by firing lasers at it.
The offense bot starts out with 3 lives, and each laser by default
will make the offense bot lose 1 life. If the offense bot loses all
of their lives, it will lose the flag and be teliported back to the start.

Also, for every 3 kills the defense bot gets, the offense bot will lose
1 flag.
@section{Where to work}

Each kind of robot (defense or offense) has its own library of
commands.  If you look in the @racket[manias/ctf] directory, you should find
three files, with starting templates and some very basic bots to build
off of.

@itemlist[

@item{@racket[offense.rkt] is for writing your offense bot.}

@item{@racket[defense.rkt] is for writing your defense bot.}

@item{@racket[together.rkt] brings them both together. This is where
  you click "run" to start the game.}

]

Here's an overview of the commands you have at your disposal for
controlling your bot.  Some of the commands work for both bots, and
some are only available for offense or defense.

@section{Common commands}

@defproc[
(set-motors [left number?] [right number?])
nothing?
]{

The left and right motors on your car determine the force on that side
of the car.  The power to each motor ranges from -1 (maximum push in
the reverse direction) to 1 (maximum push forward).

Numbers beyond the range from -1 to 1 have no extra effect, so
@racket[(set-motors -10 5)] does the same thing as @racket[(set-motors
-1 1)].

Some examples.

@itemlist[

 @item{@racket[(set-motors -1 1)] will cause your car to turn left, without
    accelerating forward or backwards}

 @item{@racket[(set-motors 1 0.5)] will cause your car to circle forward and to
    the right.}
]}

@defproc[
(get-left-input)
number?
]

@defproc[
(get-right-input)
number?
]

These calls allow you to read off the state of your motors.  So, if in
a previous round you called @racket[(set-motors 0.3 0.6)], then
@racket[(get-left-input)] will return 0.3, and
@racket[(get-right-input)] will return 0.6

@defproc[
(radians-mode) 
nothing?
]
@defproc[
(degrees-mode)
nothing?
]

These calls allow you to either use radians or degrees.

@defproc[
(normalize-angle [angle angle?]) angle?
]{
  @racket[(normalize-angle angle)] returns an angle with equivilant direction, but between
  180 and -180 if you are in degree mode, or between pi and -pi if you are in radians mode.

  For example, in degrees mode, @racket[(normalize-angle 320)] will return @racket[-40].
}

@defproc[
(angle-to-opp)
number?

]{

Returns the angle to the opponent, relative to the bot's current
direction.  @racket[(angle-to-opp)] returns i0 if the opponent is
directly in front of the bot, a positive angle if it's to your left,
and a negative angle if it's to your right.

Whether the value is returned in radians or degrees depends on the
mode you're running in.

}

@defproc[
(dist-to-opp) distance?
]{

Returns the distance to the opponent.}

@defproc[
(angle-to-flag) angle?]{

Like @racket[angle-to-opp], except for the flag.
Note that it still works when the flag has been picked up by your
opponent!}

@defproc[
(dist-to-flag) distance?]{

Like @racket[dist-to-opp], except for the flag instead of the
opponent.}


@defproc[
(get-robot-angle) angle?]{

This returns the absolute angle of your angle.  i.e., 0 degrees means
you're pointed to the left, 90 degrees is straight up, 180 degrees is
to the left, and so on.}

@defproc[
(get-opp-angle) angle?]{

Like @racket[get-robot-angle], but for your opponent!}

@defproc[
(looking-dist [theta angle?]) distance?]{

tells you how much distance there is to the next obstacle, be it a
wall, a robot or a laser.}

@section{Defense bot}

These calls are only for the defense bot, and you should only use them
in @racket[defense.rkt].

@defproc[
(shoot-laser) nothing?]{

@racket[(shoot-laser)] fires a laser in the direction your car is
pointed.  But you can't do it too often! Note that you can't always
shoot a laser. That's what the next command is for.}

@defproc[
  (load-laser) nothing?
]{
  (load-laser) loads the laser onto the front of your defense bot.
  Every few ticks (if you want to know, you can figure it out!)
  while the laser is loaded it will get darker and therefore able to knock out one
  more of the offense bot's lives. After it has a power of 3, rather than getting
  strong, your laser will simply restock.

  While your laser is loaded, you cannot give input to your motors.
}

@defproc[
(laser-cooldown-left) nothing?]{

@racket[(laser-cooldown-left)] tells you how many ticks need to elapse
until you can fire or load your laser again.}


@section{Offense bot}

@defproc[
  (boost) nothing?
]{

If your cooldown from the previous boost is over, @racket[(boost)]
will immediatly give you a speed multiplier, as well as increase the
power of your motors for a couple of seconds.  }

@defproc[
  (boost-cooldown-left) integer?
]{

@racket[(boost-cooldown-left)] will return the number of ticks until
you can use @racket[(boost)] again.  }

@defproc[
  (opp-just-fired?) bool?
]{

  @racket[(opp-just-fired?)] will tell you if this past tick, the
defense bot fired.  }
