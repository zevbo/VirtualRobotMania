#lang racket
(require "offense.rkt")

(require "simple-defense.rkt")

(define (on-tick tick#)
  (set-motors 1 1))

(define offense-bot (make-robot "Anti Cashuu" on-tick #:name-color "white"))
(run-double offense-bot my-robot offense-bot my-robot)