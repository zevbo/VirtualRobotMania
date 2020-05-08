#lang racket
(require "../robot.rkt")
(require "canvas-edges.rkt")
(require "../geo/geo.rkt")
(provide map-intersections
         map-intersect?
         robot-edges)

(define (robot-edges robot)
  (define edges
    (get-edges (robot-length robot) (robot-width robot) #:as-list? #t))
  (map
   (lambda (edge) (add-p-to-ll (rotate-ll edge (robot-angle robot)) (robot-point robot)))
   edges))

;; eventually must be corrected to use line-segments
(define (map-intersections robot map-edges)
  (flatten
   (map
    (lambda (robot-edge)
      (filter (lambda (intersection) (not (equal? intersection (void))))
              (map (lambda (map-edge) (intersection robot-edge map-edge)) map-edges)))
    (robot-edges robot))))
(define (map-intersect? robot map-edges)
  (not (empty? (map-intersections robot map-edges))))