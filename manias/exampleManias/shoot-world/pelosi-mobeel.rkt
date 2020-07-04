#lang racket
(require "../../../lib/worlds/shoot-world/shoot-world.rkt")
(provide pelosi-mobeel)

(define p 0.01)
(define (on-tick tick#)
  (set-degree-mode)  ;; make sure to have this line in on-tick
  (define angle (angle-to-other-bot))
  (cond
    [(front-left-close?)  (set-motors! -1 -0.3)]
    [(front-right-close?) (set-motors! -0.3 -1)]
    [(back-left-close?)  (set-motors! 1 0.3)]
    [(back-right-close?) (set-motors! 0.3 1)]
    [(and
      (or
       (and (< (abs angle) 7) (< (dist-to-other-bot) 300))
       (and (< (abs angle) 30) (< (dist-to-other-bot) 100))
       (and (< (abs angle) 60) (< (dist-to-other-bot) 60)))
      (or true (< (get-cooldown-time) 0)))
     (set-motors! 1 1)
     (shoot)]
    [(> (get-cooldown-time) 0) (set-motors! -1 -0.7)]
    [(< (dist-to-other-bot) 125) (if (> (abs angle) 90) (set-motors! 1 0.9) (set-motors! -1 -0.7))]
    [else (set-motors! (- 1 (* p angle))
                       (+ 1 (* p angle)))] 
    )
  )

(define pelosi-mobeel
  (make-robot
   "Pelosi Mo-beel" on-tick
   #:body-color "pink"
   #:wheel-color "green"
   #:image-url "https://pyxis.nymag.com/v1/imgs/dea/e96/43d78070c0f7cff46d506c303850980bb0-nancy-pelosi.rsquare.w700.jpg"
   ))