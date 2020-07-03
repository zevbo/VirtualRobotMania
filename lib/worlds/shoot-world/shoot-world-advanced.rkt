#lang racket
(require (except-in "shoot-world.rkt" make-robot)
         (prefix-in BASE-"shoot-world-base.rkt"))
(provide
 (prefix-out "shoot-world.rkt")
 make-robot)

 (define-syntax-rule (make-robot args ...)
    (BASE-internal-make-robot 'advanced args ...))