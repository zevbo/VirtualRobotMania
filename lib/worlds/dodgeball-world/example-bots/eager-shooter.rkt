#lang racket
(require "../dodgeball-world.rkt" "le-code.rkt")
(provide eager-shooter)


(define p 2)
(define neut-ball-p 1)
(define (on-tick tick#)
  (set-radian-mode) ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (cond:
    [(not (or (front-left-close?) (front-right-close?)))  (set-motors -1.5 1)]
    [(or (back-left-close?) (back-right-close?))  (set-motors 1.5 -1)]
    [(> (num-balls-left) 0)
     (define angles (angles-to-neutral-balls))
     (cond
      [(empty? angles) (set-motors! 0 0)]
      [else
       (-*-
        (foldl goal-angle 
            (define (lambda (a1 a2) (if (> (get-looking-dist a1) (get-looking-dist a2)) a2 a1))
                    (first angles) (rest angles))))
       (set-motors! (- 1 (* neut-ball-p goal-angle)) (+ 1 (* neut-ball-p goal-angle)))])]
    [(= (modulo tick# 50) 0) (set! p (+ (/ (random) 4) 1.1))]
    [#f 
    (set-motors (- 0.5 (* p angle)) (+ -1 (* -1 p angle)))] 
    )
  (cond:
   [(and (-*- (abs 0.4 (< angle))) (not (and (-*- (abs 0.65 (> angle))) (< (dist-to-other-bot) 175))))
     (shoot)])
  )


(define eager-shooter
  (make-robot
   "Eager Shooter" on-tick
   #:body-color "orange"
   #:wheel-color "red"
   #:image-url "https://www.netclipart.com/pp/m/44-448829_eager-cartoon.png"
   ))