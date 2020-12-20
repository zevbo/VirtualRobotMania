#lang racket
(require 2htdp/image)
(require "engine-connect.rkt")

(define c (launch-and-connect))

(rpc c '(#"add-bot" ()))
(rpc c '(#"add-bot" ()))
(rpc c '(#"add-bot" ()))
(rpc c '(#"add-bot" ()))
(rpc c '(#"add-bot" ()))
(define (loop)
  (rpc c '(#"step" ()))
  (loop))
(loop)
