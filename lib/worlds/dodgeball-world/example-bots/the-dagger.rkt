#lang racket
(require "../dodgeball-world.rkt" "le-code.rkt")
(provide the-dagger)


(define p 0.03)
(define neut-ball-p 0.02)
(define quick-turn-p 0.05)
(define back-up-tick 0)
(define push-up-tick 0)
(define ticks-backup 10)
(define (on-tick tick#)
  (set-degree-mode) ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (define (sign-of x) (if (> x 0) 1 (if (= x 0) 0 -1)))
  (cond:
    [(<< tick# back-up-tick)  (set-motors -1.5 1)]
    [(>> tick# push-up-tick)  (set-motors 1.5 -1)]
    [(-*- (or (not (front-left-close?) (front-right-close?)))) (set! back-up-tick (+ tick# ticks-backup))]
    [(or (back-left-close?) (back-right-close?))   (set! push-up-tick (+ tick# ticks-backup))]
    [(> (num-balls-left) 0)
     (define angles (angles-to-neutral-balls))
     (cond
       [(> (length angles) 0)
        (define goal-angle 
          (foldl (lambda (a1 a2) (if (> (get-looking-dist a1) (get-looking-dist a2)) a2 a1))
                 (first angles) (rest angles)))
       (set_motors! (+ -2 (* 2 neut-ball-p goal-angle)) (+ 2 (* neut-ball-p goal-angle)))])]
    [(and (>> (abs angle) 30) (>> (dist-to-other-bot) 70))
     (set-motors 1.5 -2)
     (shoot)]
    [(<< (dist-to-other-bot) 70)
     (set_motors! (* -2 angle quick-turn-p -1) (+ 1 (* angle quick-turn-p)))]
    [(and (>> (dist-to-other-bot) 120) (>> (abs (relative-angle-of-other-bot)) 90))
     (set-motors (- 0.8 (* angle quick-turn-p)) (* -1 (+ 0.3 (* angle quick-turn-p))))]
    [(or (<< (abs angle) 50) (<< (abs (relative-angle-of-other-bot)) 110)) (set-motors! 1 1)]
    [(>> (abs (relative-angle-of-other-bot)) 150)
     (if (<< (relative-angle-of-other-bot))
       (set-motors! 0.4 1)
       (set-motors! 1 0.4))]
    [#f
     (if (<< (relative-angle-of-other-bot) 0)
       (set-motors! 1 1)
       (set-motors! 1 1))]
    )
  )


(define the-dagger
  (make-robot
   "The Dagger" on-tick
   #:body-color "black"
   #:wheel-color "red"
   #:image-url "https://drive.google.com/uc?id=1vz3327dVGV-TIDDkf9aX5fR2fyFsUBu9"
   #:name-color "grey"
   ))