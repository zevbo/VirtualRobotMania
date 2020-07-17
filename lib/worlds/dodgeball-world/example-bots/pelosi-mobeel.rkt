#lang racket
(require "../dodgeball-world.rkt" "le-code.rkt")
(provide pelosi-mobeel)

(define p 0.01)
(define neut-ball-p .012)
(define (on-tick tick#)
  (set-degree-mode)  ;; make sure to have this line in on-tick
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
    [(and
      (or
       (and (< (abs angle) 7) (< (dist-to-other-bot) 300))
       (and (< (abs angle) 30) (< (dist-to-other-bot) 100))
       (and (< (abs angle) 60) (< (dist-to-other-bot) 60)))
      (or true (< (get-cooldown-time) 0)))
     (set-motors! 1 1)
     (shoot)]
    [(<= (get-cooldown-time) 0) (set_motors! 2 0.3)]
    [(< (dist-to-other-bot) 125) (if (> (abs angle) 90) (set-motors! 1 0.8) (set-motors! -1 -0.8))]
    [#f (set_motors! (- (* 2 p angle) 2) (+ 2 (* p angle)))] 
    )
  )

(define pelosi-mobeel
  (make-robot
   "Pelosi Mo-beel" on-tick
   #:body-color "pink"
   #:wheel-color "green"
   #:image-url "https://pyxis.nymag.com/v1/imgs/dea/e96/43d78070c0f7cff46d506c303850980bb0-nancy-pelosi.rsquare.w700.jpg"
   ))