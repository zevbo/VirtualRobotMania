#lang racket
(require 2htdp/image)
(require "../engine-connect.rkt")
(require "../robotVisualization.rkt")
(provide all-defined-out)

(define (set-robot-image c defense? image)
  (define file (make-temporary-file "test-robot-~a.png"))
  (println file)
  (save-image image file)
  (define msg
    (if defense?
           `(#"set-defense-image"
             ,(path->bytes file))
           `(#"set-offense-image"
             ,(path->bytes file))))
  (println msg)
  (rpc c msg)
  (delete-file file))

(define (use_defense_bot c path) (rpc c '("use_defense_bot" ())))
(define (use_offense_bot c path) (rpc c '("use_offense_bot" ())))
(define (step c) (rpc c `(#"step" ())))
(define (set-motors c l r) (rpc c '("set_motors" (,l ,r))))
(define (l_input c) (rpc c '("l_input" ())))
(define (r_input c) (rpc c '("r_input" ())))
(define (boost c) (rpc c '("r_boost" ())))
(define (enhance_border c) (rpc c '("enhance_border" ())))
(define (num_flags c) (rpc c '("num_flags" ())))
(define (launch-and-connect) (launch-and-connect "ctf"))
