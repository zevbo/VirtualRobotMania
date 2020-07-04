#lang racket
(require (except-in "dodgeball-world.rkt" make-robot)
         (prefix-in BASE-"dodgeball-world-base.rkt"))
(provide
 (prefix-out "dodgeball-world.rkt")
 make-robot)

 (define-syntax-rule (make-robot args ...)
    (BASE-internal-make-robot 'advanced args ...))