#lang racket
(require "defense.rkt")
(provide my-robot)

(define (on-tick tick#)
  (void))

(define my-robot (make-robot "Cashu 2.0" on-tick))