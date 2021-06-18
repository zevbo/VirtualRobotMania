#lang racket
(provide (all-defined-out))

;; Currently all in degrees

(struct vec (x y))

(define (vec-add v1 v2)
  (vec (+ (vec-x v1) (vec-x v2)) (+ (vec-y v1) (vec-y v2))))
(define (vec-scale v c)
  (vec (* c (vec-x v)) (* c (vec-y v))))
(define (vec-sub v1 v2) (vec-add v1 (vec-scale v2 -1)))

(define (rotate v theta)
  (vec (+ (* (cos theta) (vec-x v)) (* -1 (sin theta) (vec-y v)))
       (+ (* (sin theta) (vec-x v)) (* (cos theta) (vec-y v)))))

(define (polar r theta)
  (vec (* r (cos theta)) (* r (sin theta))))

(define (angle-of vec)
  (atan (vec-y vec) (vec-x vec)))

(define (mag vec)
  (sqrt (expt (vec-x vec) 2) (expt (vec-y vec) 2)))
(define (dist v1 v2)
  (mag (vec-sub v1 v2)))