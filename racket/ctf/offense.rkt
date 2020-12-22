#lang racket
(require "../engine-connect.rkt")
(require "driver.rkt")
(provide all-defined-out)

(define make-robot (make-make-robot 'offense))

(define (set-motors c l r)
  (rpc c (query #"set-motors" `(,l ,r))))

(define (boost c)
  (rpc c (query #"boost" `())))

(define run run)
