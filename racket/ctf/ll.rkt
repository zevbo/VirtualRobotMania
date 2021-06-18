#lang racket
(require "vector.rkt")
(provide intersection
         line-pp
         ray-pa
         line-segment-pp)

(define delta 1)
(define epsilon 0.0001)

(struct ll (p1 p2 contains?))

(define (intersection l1 l2)
  ;; Algorithim: http://geomalgorithms.com/a05-_intersect-1.html
  (define u (vec-sub (ll-p2 l1) (ll-p1 l1)))
  (define v (vec-sub (ll-p2 l2) (ll-p1 l2)))
  (define w (vec-sub (ll-p1 l1) (ll-p1 l2)))

  (define s (/ (- (* (vec-y v) (vec-x w)) (* (vec-x v) (vec-y w)))
               (- (* (vec-x v) (vec-y u)) (* (vec-y v) (vec-x u)))))

  (define p (vec-add (ll-p1 ll) (vec-scale u s)))

  (if (and ((ll-contains? l1) p) ((ll-contains? l2) p))
      p
      #f))

(define (line-pp p1 p2)
  (define (contains? p)
    (<
     (-
      (* (- (vec-y p) (vec-y p1)) (- (vec-x p2) (vec-x p)))
      (* (- (vec-x p) (vec-x p1)) (- (vec-y p2) (vec-y p))))
     epsilon))
  (ll p1 p2 contains?))

(define (line-pa p angle)
  (line-pp p (polar epsilon angle)))

(define (ray-pa p1 angle)
  (define p2 (polar epsilon angle))
  (define line (line-pp p1 p2))
  (define (contains? p)
    (define a1 (angle-of (vec-sub p p1))) 
    (define a2 (angle-of (vec-sub p2 p1))) 
    (and
     ((ll-contains? line) p)
     (< (abs (- a1 a2)) 90)))
  (ll p1 p2 contains?))

(define (in-bounds n bound1 bound2)
  (or
   (and (>= n bound1) (<= n bound2))
   (and (<= n bound1) (>= n bound2))))

(define (line-segment-pp p1 p2)
  (define line (line-pp p1 p2))
  (define (contains? p)
    (and
     ((ll-contains? line) p)
     (in-bounds (vec-x p) (vec-x p1) (vec-x p2))
     (in-bounds (vec-y p) (vec-y p1) (vec-y p2))))
  (ll p1 p2 contains?))

(define (angle-of-line ll)
  ; This is kinda whack cause it means that (ll p1 p2) \neq (ll p2 p1)
  (angle-of (vec-sub (ll-p2 ll) (ll-p1))))