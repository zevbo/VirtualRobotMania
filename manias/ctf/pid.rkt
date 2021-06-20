#lang racket
(provide pid-init pid-update pid-eval pid-d)

(struct pid
  (kp ki kd [p #:mutable] [i #:mutable] [d #:mutable])
  #:transparent)

(define (pid-init kp kpred)
  (pid kp 0 (* kp kpred) 0 0 0))

(define (pid-update pid p)
  (set-pid-d! pid (- p (pid-p pid)))
  (set-pid-p! pid p)
  (set-pid-i! pid (+ (pid-i pid) p)))

(define (pid-eval pid)
  (+
   (* (pid-kp pid) (pid-p pid))
   (* (pid-ki pid) (pid-i pid))
   (* (pid-kd pid) (pid-d pid))))
