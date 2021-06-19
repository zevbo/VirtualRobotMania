Note: if you are using this code, it is assumed you will be working in (radians-mode)

@section{Vector}

To use vectors, make sure to put @racket[(require "../../racket/ctf/vector.rkt")] 
at the top of your file.

@defproc[
    (vec [x number?] [y number?]) vec?
]

@defproc[(vec-x [vec vec?]) number?]
@defproc[(vec-y [vec vec?]) number?]

@racket[(vec x y)] will return a value with the given x and y stored
in it. You can then get out those values using @racket[vec-x] and 
@racket[vec-y]. For example @racket[(vec-y (vec 1 2.5))] returns
2.5.

@defproc[(vec-add [vec1 vec?] [vec2 vec?]) vec?]{
    Returns a new vector which is the sum vec1 and vec2
}
@defproc[(vec-sub [vec1 vec?] [vec2 vec?]) vec?]{
    Returns a new vector which is vec1 minus v2
}
@defproc[(vec-scale [vec vec?] [c number?]) vec?]{
    Returns a new vector which is vec1 scaled the c
}

@defproc[(rotate [vec vec?] [angle number?]) vec?]{
    Returns a new vector that is vec rotated angle radians to the right
}

@defproc[(polar [r number?] [angle number?])]{
    Returns a vector whose magnitude is r and whose angle with the positive x-axis is angle
}
@defproc[(angle-of [vec vec?]) number?]{
    Returns the angle that vec makes with the positive x-axis
}
@defproc[(mag [vec vec?]) number?]{
    Returns the magnitude of vec
}
@defproc[(dist [vec1 vec?] [vec2 vec?]) number?]{
    Returns the distance between vec1 and vec2
}

@section{Line Like}

To use line like, make sure to put @racket[(require "../../racket/ctf/ll.rkt")] 
at the top of your file.

A "line like" (not a real term) is any shape that is a subset of a single line.
The three that we are dealing with are:
- Lines 
- Rays 
- Line Segments
When we say line like, or ll, we are referring to any one of these 3 shapes.

@defproc[(line-pp [p1 vec?] [p2 vec?]) ll?]{
    Returns a line like that is treated as the line that goes through p1 and p2
}
@defproc[(line-pa [p vec?] [angle number?]) ll?]{
    Returns a line like that is treated as the line that starts at p, 
    and travels in the direction of the given angle
}
@defproc[(ray-pa [p vec?] [angle number?]) ll?]{
    Returns a line like that is treated as the ray that starts at p, 
    and travels in the direction of the given angle
}
@defproc[(line-segment-pp [p1 vec?] [p2 vec?]) ll?]{
    Returns a line like that is treated as the line segment 
    with ends at p1 and p2
}
@defproc[(angle-of-ll [ll ll?]) number?]{
    Returns the angle above or below the positive x-axis of the line.
    The value of angle-of-ll will always be in [-90,90)
}
@defproc[(ll-p1 [ll ll?]) vec?]{
    Returns one point on the line like. If it's a line segment or a ray
    it will be one of its end points.
}
@defproc[(ll-p2 [ll ll?]) vec?]{
    Same as @racket[ll-p1] except 
}