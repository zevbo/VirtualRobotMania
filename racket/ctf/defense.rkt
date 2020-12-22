#lang racket
(require "../engine-connect.rkt")
(require "driver.rkt")
(provide all-defined-out)

(define make-robot (make-make-robot 'defense))

(define (set-motors c l r)
  (rpc c (query #"set-motors" `(,l , r))))
