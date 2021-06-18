#lang scribble/manual

@title{Welcome to Virtual Robotics}

If you're here, you're probably looking for some documentation for the
Virtual Robotics competition, specifically, the CTF (Capture the Flag)
edition!

@section{Getting Started}

@itemlist[

    @item{@bold{Download DrRacket} from
       @link["https://download.racket-lang.org/"]{here} and install
       it.}

    @item{You can @bold{get the code}
      @link["https://github.com/zevbo/VirtualRobotMania"]{from
      github}.  The best way to do that is to use git.  If you don't
      know how, ask for help!}

    @item{@bold{Open DrRacket}}

    @item{@bold{Open the files.} In DrRacket, click file -> open (on
      the top) and navigate to VirtualRobotMania/manias/.  Then open
      up the example in @racket{manias/ctf/together.rkt} from inside
      DrRacket.}

    @item{@bold{Install packages.} There are two racket packages you
    need: @racket[csexp] and @racket[rfc6455]. If you click the run
    button on the top right, you'll get an error, with an embedded
    link offering to update the racket package directory. Click on it!
    Then try again, and it will offer you the chance to install a
    missing package.  Keep on doing this until they're all installed.}

    @item{@bold{Start the game.}  Press run button in the top right.  That
    should launch the game in a web-browser tab.  The robots won't be
    doing anything too interesting yet, but now you have everything
    you need to work on your robots.  Go @link["ctf.html"]{here} to
    learn more about the game.}
]

@section{Learning Racket}

@itemlist[

 @item{A @link["racket-cheatsheet.html"]{cheatsheet} and short
 introduction to Racket that was written by us!}

 @item{A
 @link["https://cs.uwaterloo.ca/~plragde/flaneries/TYR"]{tutorial for
 people who are already programmers}.  It's clear and concise, but is
 probably not as good for someone now to programming.}

 @item{@link["https://docs.racket-lang.org/reference/"]{The Racket
 Manual}. Most people shouldn't need this, but if you do, Racket's
 manual is well written and well organized.

 Note that the manual has a pretty good search mechanism, so you can
 type in search terms in the bar on the upper left.}

 @item{@link["https://learnxinyminutes.com/docs/racket/"]{Learn X in Y
 minutes} has some more detailed coverage of how to use Racket, with
 lots of examples.}

 ]

@section{The Game}


Read more about @link["ctf.html"]{capture the flag}, our latest game!

@section{Geometry}

For the more advanced players, it will likely be helpful to create a
more precise description of the physical geometry of the game.

In order to make that slightly more possible, we have provided some code
that you can trust works. That way, it will be easier to make progress
and you won't feel like you are simply walking in circles.

Documentation for using this code can be found @link["geometry.html"]{here}.

@section{Algorithms}

An algorithim simply means the method that we use to decide what we
will do.  Read more about some simple
@link["algorithms.html"]{standard algorithms} we think are helpful.