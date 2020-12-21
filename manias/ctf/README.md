Welcome to a new Virtual Robotics competition! This year's competition
is a game of capture the flag, and the game is more challenging than
ever.

# Overview

The game is played between two different kinds of robots:

- An *offense bot*, whose goal is to capture the flag, and bring it
  back to its home base.
- A *defense bot* whose goal is to stop the offense bot from getting
  the flag.

The defense bot has two ways of interfering with the offense bot: it
can get in its way, and it can fire bullets at it.

Also, tournaments will be in teams, bughouse style!

Each team consists of an offense bot and a defense bot.  Both your bot
and your team-mate's bot will play in concurrent games.  Victories by
your bot will provide advantages to your team-mate's bot, and
vice-versa.  But more on that below.

# Logging in

For various reasons, we decided to set up a server that people could
connect to to program their bots, rather than having to get software
installed on everyone's box.  We'll send instructions in a separate
email.

# Robot APIs

Each kind of robot (defense or offense) has its own library of
commands.  You should make sure you have the right require at the top
of your file.  You should uncomment one of the following two lines to
choose what kind of bot you're creating.

```scheme
;(require "../../lib/worlds/ctf/offense.rkt")
;(require "../../lib/worlds/ctf/defense.rkt")
```

Here are the APIs that you can use for each kind of bot, along with
some documentation about the restrictions for each bot type.

## Both bots

A lot of the controls are shared between the two bots.  Here's the
shared API:

### set-motors

The left and right motors on your car determine the force on that side
of the car.  The power to each motor ranges from -1 (maximum push in
the reverse direction) to 1 (maximum push forward).

`(set-motors left right)` sets the force being put into each side of
the robot.  Numbers beyond the range from -1 to 1 have no extra
effect, so `(set-motors -10 5)` does the same thing as `(set-motors -1
1)`.

Some examples.

  - `(set-motors -1 1)` will cause your car to turn left, without
    accelerating forward or backwards.
  - `(set-motors 1 0.5)` will cause your car to circle forward and to
    the right.

### get-motor-left/right

These calls allow you to read off the state of your motors.  So, if in
a previous round you called `(set-motors 0.3 0.6)`, then
`(get-motor-left)` will return 0.3, and `(get-motor-right)` will
return 0.6

## Defense bot

Here are the defense-bot-only calls.

### shoot

This one is easy! `(shoot)` fires a bullet in the direction your car
is pointed.  But you can't do it too often! You can only shoot every
50 ticks!

## Offense bot

Here are the offense-bot-only calls.

- boost
- opponent-angle
- opponent-distance
- opponent-shot?
- flag-angle
