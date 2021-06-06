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

You might noticed that we used square brackets in the above. That's
just a style thing.  Square brackets and parens can be used
interchangeably.

All of the bits of syntax we defined above can be used together, i.e.,
you can define a function inside of a branch of a conditional, or
define a value inside of a function.

@section{Data types and functions}

@subsection{Numbers and Booleans}

Racket comes with a bunch of built in datatypes. We've already
encountered @bold{numbers} in Racket, which mostly work the way you'd expect.

Another really basic data type is the @bold{boolean}, which is either true or
false You get these as the result of things like comparisons, and
there are logical operations for combining them.

@interaction[
(> 3 4)
(not (> 3 4))
(or (> 3 4) (<= 3 4))
]

@subsection{Lists}

Another common data type is the @bold{list}.  You can construct a list
using the @racket[list] function.

@defproc[#:link-target? #f
         (list [element any?] ...)
         list?]

@interaction[
(list 1 3 2)
]

And there are a bunch of functions for working on lists.  For example,
there's a function called @racket[filter], which takes two arguments:
a function and a list.

@defproc[
#:link-target? #f
(filter [include? func?] [list list?])
list?]

@racket[filter] applies that function to each element of the list, and
returns an new list containing just the elements for which the
function returned true.

@interaction[
(define (is-odd x) (= (modulo x 2) 1))
(filter is-odd (list 1 3 2))
]

When using a function like this that takes functions as an argument,
it's sometimes nice to use a lighter-weight syntax for creating a
function without naming it, called a @bold{lambda} or an
@bold{anonymous function}.  Here's the same example using a lambda
instead of a separately defined function.

@interaction[
(filter
  (lambda (x) (= (modulo x 2) 1))
  (list 1 3 2))
]

Another really useful function is map, which can transform the
elements of a list.

@defproc[
#:link-target? #f
(map [transform func?] [list list?])
list?]

@interaction[
(map
  (lambda (x) (* x 2))
  (list 1 2 3))
]

You can also fetch particular items out of a list.

@defproc[
#:link-target? #f
(list-ref [list list?] [pos int?])
any?]

Note that indexing starts at 0, not 1!

@interaction[
(define l (list 1 2 3))
(list-ref l 0)
(list-ref l 2)
]

You'll see errors if you go out of bounds.

@interaction[
(define l (list 1 2 3))
(list-ref l -1)
(list-ref l 3)
]
