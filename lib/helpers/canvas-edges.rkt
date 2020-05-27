#lang racket
(require "../geo/geo.rkt")
(provide get-corners get-edges define-list-values)

(define-syntax-rule (define-list-values (var-names ...) value-list)
  (begin
    (define remaining-values value-list)
    (begin
      (define var-names (first remaining-values))
      (set! remaining-values (cdr remaining-values))) ...))

(define (get-corners width height #:rotate [rotation 0] #:shift-by [shift-by (point 0 0)])
  (define tr (point (/ width  2) (/ height  2)))
  (define br (point (/ width  2) (/ height -2)))
  (define tl (point (/ width -2) (/ height  2)))
  (define bl (point (/ width -2) (/ height -2)))
  (map
   (lambda (p) (add-points (rotate-point p rotation) shift-by))
   (list tr br tl bl)))

(define (get-edges width height #:rotate [rotation 0] #:shift-by [shift-by (point 0 0)])
  (define-list-values (tr br tl bl) (get-corners width height #:rotate rotation #:shift-by shift-by))
  (define top   (line-seg tr tl))
  (define right (line-seg br tr))
  (define bot   (line-seg bl br))
  (define left  (line-seg tl bl))
  (list top right bot left))
   