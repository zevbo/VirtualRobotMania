#lang racket
(require 2htdp/image)
(require "engine-connect.rkt")

(define c (launch-and-connect))

(define (set-robot-image i image)
  (define file (make-temporary-file "image-~a.png"))
  (println file)
  (save-image image file)
  (rpc c `(#"load-bot-image"
           (,(string->bytes/latin-1 (~v i))
            ,(path->bytes file))))
  #;(delete-file file))

(for ([i (in-range 30)])
  (set-robot-image i (square 30 'solid 'red))
  (rpc c '(#"add-bot" ())))
(define (loop)
  (rpc c '(#"step" ()))
  (loop))
(loop)
