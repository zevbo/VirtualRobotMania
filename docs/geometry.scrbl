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