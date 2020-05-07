#lang racket
(require "geo.rkt")

(define (get-corners width height)
  (define tr (point (/ width  2) (/ height  2)))
  (define br (point (/ width  2) (/ height -2)))
  (define tl (point (/ width -2) (/ height  2)))
  (define bl (point (/ width -2) (/ height -2)))
  (values tr br tl bl))

(define (get-edges width height)
  (define-values (tr br tl bl) (get-corners width height))
  (define top   (line tr tl))
  (define right (line br tr))
  (define bot   (line bl br))
  (define left  (line tl bl))
  (values top right bot left))
   