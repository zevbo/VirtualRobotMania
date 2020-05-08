#lang racket
(require "point.rkt")
(provide (struct-out line) (struct-out line-seg)
         get-p1 get-p2 to-line
         )


(struct line (p1 p2) #:transparent)
(struct line-seg (p1 p2) #:transparent)
(struct ray (p-end p-dir) #:transparent)

(define (get-p1 ll) (line-p1 (to-line ll)))
(define (get-p2 ll) (line-p2 (to-line ll)))

(define (to-line ll)
  (match ll
    [(line p1 p2) (line p1 p2)]
    [(line-seg p1 p2) (line p1 p2)]
    [(ray p-end p-dir) (line p-end p-dir)]))