#lang racket
(require "../robot.rkt")
(require "canvas-edges.rkt")
(require "../geo/geo.rkt")
(provide map-robot-intersections map-robot-intersect?
         robot-edges
         map-ll-intersections closest-intersection)

(define (robot-edges robot)
  (define edges
    (get-edges (robot-length robot) (robot-width robot) #:as-list? #t))
  (map
   (lambda (edge) (add-p-to-ll (rotate-ll edge (robot-angle robot)) (robot-point robot)))
   edges))

;; eventually must be corrected to use line-segments
(define (map-robot-intersections map-edges robot)
  (flatten
   (map
    (lambda (robot-edge)
      (filter (lambda (intersection) (not (equal? intersection (void))))
              (map (lambda (map-edge) (intersection robot-edge map-edge)) map-edges)))
    (robot-edges robot))))
(define (map-robot-intersect? map-edges robot)
  (not (empty? (map-robot-intersections map-edges robot))))

(define (map-ll-intersections map-edges ll)
  (map (lambda (edge) (intersection edge ll))
       (filter (lambda (edge) (intersect? edge ll)) map-edges)))
(define (closest-intersection map-edges robot ll)
  (define intersections (map-ll-intersections map-edges ll))
  (define (dist-to-robot p) (dist p (robot-point robot)))
  (define closest (first (sort intersections < #:key dist-to-robot)))
  (cons closest (dist-to-robot closest)))