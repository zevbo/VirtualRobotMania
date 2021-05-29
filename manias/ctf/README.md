# Capture the Flag!

Welcome to a new Virtual Robotics competition! This year's competition
is a step up in the complexity of the tasks, but writing bots should
still be easy for beginners.

Everyone is going to work in teams of two, and those teams need to
make two different robots together:

- An *offense bot*, whose goal is to capture the flag, and bring it
  back to its home base.
- A *defense bot* whose goal is to stop the offense bot from getting
  the flag.

The defense bot has two ways of interfering with the offense bot: it
can get in the other bot's way, and it can fire (strangely
slow-moving) lasers at it.

# Where to work

Each kind of robot (defense or offense) has its own library of
commands.  If you look in the `manias/ctf` directory, you should find
three files, with starting templates and some very basic bots to build
off of.

- `offense.rkt` is for writing your offense bot.
- `defense.rkt` is for writing your defense bot.
- `together.rkt` brings them both together. This is where you click
  "run" to start the game.

Here's an overview of the commands you have at your disposal for
controlling your bot.  Some of the commands work for both bots, and
some are only available for offense or defense.

## Common commands

### `set-motors`

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

### `get-motor-left/right`

These calls allow you to read off the state of your motors.  So, if in
a previous round you called `(set-motors 0.3 0.6)`, then
`(get-left-input)` will return 0.3, and `(get-right-input)` will
return 0.6

### `angle-to-opp` and `dist-to-opp`

These functions let you figure out where your opponent is, relative to
you.  `(angle-to-opp)` returns 0 if the opponent is directly in front
of you, a positive angle if it's to your left, and a negative angle if
it's to your right.

`(dist-to-opp)` simply returns the distance to the opponent.

### `angle-to-flag` and `distance-to-flag`

Just like the above, except for the flag, instead of your opponent.
Note that it still works when the flag has been picked up by your
opponent!

### `get-robot-angle` and `get-opp-angle`

This returns the absolute angle of your angle.  i.e., 0 degrees means
you're pointed to the left, 90 degrees is straight up, 180 degrees is
to the left, and so on.

`get-opp-angle` gives the same number, but for your opponent!

### `looking-dist`

`(looking-dist theta)` tells you how much distance there is to the
next obstacle, be it a wall, a robot or a laser!

## Defense bot

Here are the defense-bot-only calls.

### `shoot-laser`

`(shoot-laser)` fires a bullet in the direction your car is pointed.
But you can't do it too often! Note that you can't always shoot a
laser. That's what the next command is for.

### `laser-cooldown-left`

`(laser-cooldown-left)` tells you how many ticks need to elapse until
you can fire your laser again.

### `(opp-just-boosted?)`

This lets you tell if your opponent has just called `(boost)`!  See
the offense bot section above to see what boost does!


## Offense bot

Here are the offense-bot-only calls.

- boost
- opponent-angle
- opponent-distance
- opponent-shot?
- flag-angle
