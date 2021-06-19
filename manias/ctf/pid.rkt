#lang racket
(provide pid-init pid-update pid-eval)

(struct pid
  (kp ki kd [p #:mutable] [i #:mutable] [d #:mutable])
  #:transparent)

(define (pid-init kp ki kd)
  (pid kp ki kd 0 0 0))

(define (pid-update pid p)
  (set-pid-p! pid p)
  (set-pid-i! pid (+ (pid-i pid) p))
  (set-pid-d! pid (- p (pid-p pid))))

(define (pid-eval pid)
  (+
   (* (pid-kp pid) (pid-p pid))
   (* (pid-ki pid) (pid-i pid))
   (* (pid-kd pid) (pid-d pid))))
