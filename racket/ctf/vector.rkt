#lang racket

;; Currently all in degrees

(struct vec (x y))

(define (vec-add v1 v2)
  (vec (+ (vec-x v1) (vec-x v2)) (+ (vec-y v1) (vec-y v2))))
(define (vec-scale v c)
  (vec (* c (vec-x v)) (* c (vec-y v))))
(define (vec-sub v1 v2) (vec-add v1 (vec-scale v2 -1)))

(define (rotate v theta)
  (set! theta (degrees->radians theta))
  (vec (+ (* (cos theta) (vec-x v)) (* -1 (sin theta) (vec-y v)))
       (+ (* (sin theta) (vec-x v)) (* (cos theta) (vec-y v)))))