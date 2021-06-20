#lang racket
(require "../../racket/ctf/offense.rkt")
(provide offense-bot)


(define backup-params-store 'nil)

(define (backup-params)
  (cond
    [(eq? 'nil backup-params-store)
     (define (value)
       (- (/ (random 1000) 1000.)))
     (set! backup-params-store (cons (value) (value)))
     ])
  backup-params-store)

(define (clear-backup-params)
  (set! backup-params-store 'nil))

(define (on-tick tick-num)
  (radians-mode)
  (define dist (looking-dist 0))
  (cond
    [(not (offense-has-flag?))
     (cond
       [(<= (angle-to-flag) 0)
        (set-motors 1 0.7)]
       [(> (angle-to-flag) 0)
        (set-motors 0.7 1)]
       )]
    [else
     (cond [(> dist 30) (clear-backup-params)])
     (cond
       [(< dist 30)
        (define params (backup-params))
        (set-motors (car params) (cdr params))]
       [(> (abs (get-robot-angle)) (* (/ 160 180) pi))
        (set-motors 1 1)]
       )]))


(define offense-bot
  (make-robot
   "Green offenders"
   on-tick
   #:body-color 'green))
