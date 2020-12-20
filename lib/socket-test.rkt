#lang racket
(require 2htdp/image)
(require "engine-connect.rkt")

(define c (launch-and-connect))

(for ([i (in-range 30)])
  (rpc c '(#"add-bot" ())))
(define (loop)
  (rpc c '(#"step" ()))
  (loop))
(loop)
