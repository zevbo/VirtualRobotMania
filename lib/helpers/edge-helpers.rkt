#lang racket
(require "../robot.rkt")
(require "canvas-edges.rkt")
(require "../geo/geo.rkt")
(provide map-robot-intersections map-robot-intersect? maps-intersections maps-intersect?
         robot-edges
         map-ll-intersections closest-intersection get-robot-map-dist maps-intersecting-lls)

(define (robot-edges robot)
  (get-edges (robot-length robot) (robot-width robot)
             #:rotate (robot-angle robot) #:shift-by (robot-point robot)))
;; eventually must be corrected to use line-segments
(define (maps-intersecting-lls map1 map2)
  (foldl append (list)
   (map
    (lambda (map1-edge)
      (map
       (lambda (map2-edge)(cons map1-edge map2-edge))
       (filter (lambda (map2-edge) (not (equal? (intersection map1-edge map2-edge) (void))))
               map2)))
    map1)))
(define (maps-intersections map1 map2)
  (flatten
   (map
    (lambda (map1-edge)
      (filter (lambda (intersection) (not (equal? intersection (void))))
              (map (lambda (map2-edge) (intersection map1-edge map2-edge)) map2)))
    map1)))
(define (maps-intersect? map1 map2)
  (not (empty? (maps-intersections map1 map2))))
(define (map-robot-intersections map-edges robot)
  (maps-intersections map-edges (robot-edges robot)))
(define (map-robot-intersect? map-edges robot)
  (maps-intersect? map-edges (robot-edges robot)))

(define (map-ll-intersections map-edges ll)
  (map (lambda (edge) (intersection edge ll))
       (filter (lambda (edge) (intersect? edge ll)) map-edges)))
(define (closest-intersection map-edges robot ll)
  (define intersections (map-ll-intersections map-edges ll))
  (define (dist-to-robot p) (dist p (robot-point robot)))
  (define closest (first (sort intersections < #:key dist-to-robot)))
  (cons closest (dist-to-robot closest)))
(define (get-robot-map-dist map-edges robot angle)
  (cdr
   (closest-intersection
    map-edges robot
    (ray-point-angle-form (robot-point robot) (+ angle (robot-angle robot))))))
