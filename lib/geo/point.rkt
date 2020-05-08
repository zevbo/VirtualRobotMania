#lang racket
(provide (struct-out point))

(struct point (x y) #:transparent)