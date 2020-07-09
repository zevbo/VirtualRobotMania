#lang racket
(require "../dodgeball-world.rkt")
(provide stationary-bot)

(define (on-tick tick#)
  (set-motors! 0 0))

(define stationary-bot
  (make-robot
   "Station- -ary Bot" on-tick
   #:body-color "grey"
   #:wheel-color "grey"
   #:name-color "white"
   ))