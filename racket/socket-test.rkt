#lang racket
(require 2htdp/image)
(require "engine-connect.rkt")

(println "whatever")
(define c (launch-and-connect "test"))
(println "started")

(define (set-robot-image i image)
  (define file (make-temporary-file "image-~a.png"))
  (println file)
  (save-image image file)
  (rpc c `(#"load-bot-image"
           (,(string->bytes/latin-1 (~v i))
            ,(path->bytes file))))
  (delete-file file))

(define (rand-color)
  (color (random 0 256) (random 0 256) (random 0 256) (random 0 256)))

(for ([i (in-range 30)])
  (set-robot-image
   i
   (overlay (circle 10 'solid (rand-color))
            (square 30 'solid (rand-color))))
  (rpc c '(#"add-bot" ())))
(define (loop)
  (rpc c '(#"step" ()))
  (loop))
(loop)
