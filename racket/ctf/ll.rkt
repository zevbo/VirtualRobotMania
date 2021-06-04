#lang racket
(require "vector.rkt")
(provide (all-defined-out))

(struct ll (p1 p2 contains))

(define (intersection l1 l2)
  ;; Algorithim: http://geomalgorithms.com/a05-_intersect-1.html
  (define u (vec-sub (ll-p2 l1) (ll-p1 l1)))
  (define v (vec-sub (ll-p2 l2) (ll-p1 l2)))
  (define w (vec-sub (ll-p1 l1) (ll-p1 l2)))

  (define s (/ (- (* (vec-y v) (vec-x w)) (* (vec-x v) (vec-y w)))
               (- (* (vec-x v) (vec-y u)) (* (vec-y v) (vec-x u)))))

  (define p (vec-add (ll-p1 ll) (vec-scale u s)))

  (if (and ((ll-contains l1) p) ((ll-contains l2) p))
      p
      #f))