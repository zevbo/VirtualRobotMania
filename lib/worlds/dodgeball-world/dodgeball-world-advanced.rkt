#lang racket
(require (except-in "dodgeball-world.rkt" make-robot)
         (prefix-in BASE-"dodgeball-world-base.rkt"))
(provide
 (all-from-out "dodgeball-world.rkt")
 make-robot)

 (define-syntax-rule (make-robot args ...)
    (BASE-internal-make-robot 'advanced args ...))