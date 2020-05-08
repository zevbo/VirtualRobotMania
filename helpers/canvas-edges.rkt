#lang racket
(require "../geo/geo.rkt")
(provide get-corners get-edges)

(define (get-corners width height #:as-list? [as-list? #f])
  (define tr (point (/ width  2) (/ height  2)))
  (define br (point (/ width  2) (/ height -2)))
  (define tl (point (/ width -2) (/ height  2)))
  (define bl (point (/ width -2) (/ height -2)))
  (if as-list?
      (list tr br tl bl)
      (values tr br tl bl)))

(define (get-edges width height #:as-list? [as-list? #f])
  (define-values (tr br tl bl) (get-corners width height))
  (define top   (line-seg tr tl))
  (define right (line-seg br tr))
  (define bot   (line-seg bl br))
  (define left  (line-seg tl bl))
  (if as-list?
      (list top right bot left)
      (values top right bot left)))
   