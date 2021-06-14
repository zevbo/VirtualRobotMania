#lang scribble/manual
@(require scribble/manual scribble/eval)


@title{A Racket Cheatsheet}

This is meant to serve two purposes: A @bold{quick reference} on
racket itself, and an @bold{introduction for people with some
programming experience}.

@section{The Basics}

For those of you with some programming experience, the neat thing
about Racket is how simple it is.  The core language is super small,
and you just need to know a few bits of syntax to get started.  In
particular:

@itemlist[
  @item{Applying functions}
  @item{Naming things (otherwise known as binding variables)}
  @item{Defining functions}
  @item{Conditionals}
 ]

Let's talk about each of these with some examples.  Along the way,
we'll learn a bit about some of the functions and data types that
Racket comes with.

@bold{Applying functions} in Racket is simple, if a little unfamiliar.  It
always looks like this:

@interaction[
(string-append "Hello" " World!")
(+ 3 4)
(+ 1 2 3 8)
]

As you can see, a function application is a parenthesized list, where
the first thing is the function, and the remaining things are the
argument to that function.  This looks pretty weird when doing
arithmetic, but you get used to it.

@bold{Naming things} is mostly done using the define syntax.

@interaction[
(define seven (+ 3 4))
(+ seven seven)
]

@bold{Defining functions} is also typically done with a variant of the
define syntax.

@interaction[
(define (double x) (* x 2))
(double 10)
]

@bold{Conditionals} are the last critical language
feature. Conditionals are what let you decide between different
statements.  There are two versions of this that come up: if and cond,
but we recommend you mostly stick to cond.  Cond lets you define an
arbitrary sequence of alternatives, with a test for each one.

Here's a really simple example: a function that constrains a number
within a range.

@interaction[
(define (clamp min max x)
  (cond
    [(> x max) max]
    [(< x min) min]
    [else x]))
(clamp 10 20 0)
(clamp 10 20 100)
(clamp 10 20 12)
]
