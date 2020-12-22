#lang racket
(require "driver.rkt")
(provide (all-defined-out))

(define make-robot (make-make-robot 'offense))

(define (set-motors l r)
  (bot-rpc #"set-motors" `(,l ,r)))

(define (boost)
  (bot-rpc #"boost" `()))
