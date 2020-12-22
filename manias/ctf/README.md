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
