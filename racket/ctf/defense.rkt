#lang racket
(require "driver.rkt")
(require "common.rkt")
(provide (all-defined-out)
         (all-from-out "common.rkt"))

(define make-robot (make-make-robot 'defense))

(define (load-laser) (bot-rpc #"load-laser" `() #f))
(define (shoot-laser) (bot-rpc #"shoot-laser" `() #f))
(define (laser-cooldown-left) (bot-rpc-num #"laser-cooldown-left" `() #t))
(define (restock-laser) (bot-rpc #"restock-laser" '() #f))
(define (next-laser-power) (bot-rpc-num #"next-laser-power" '() #t))