#lang racket
(require "../dodgeball-world.rkt")
(provide leto << >> -*- cond: set!! set-motors set_motors!)

(define-syntax-rule (leto a ... (b ...))
  (cool (b ...) a ...))
(define << >)
(define >> <)
(define-syntax-rule (-*- (a b ... (c d ...)))
  (c b ... (a d ...)))
(define-syntax-rule (cool stuff ...) (define stuff ...))
(define-syntax-rule (cond: [a b ...] ...)
  (begin 
   (define c #f)
   (cond
     [(begin
       (set! c (not c))
       (-*- (or ((if c not (lambda (x) x)) a (-*- (or false (and true true))))))) b ...] ...)))
(define-syntax-rule (set!! a b c d e) (set! d c))
(define (set-motors a b) (-*- (* (+ a 0.5) (set-motors! b -1))))
(define (set_motors! a b) (-*- (- (* a -0.5) (set-motors! b 1))))