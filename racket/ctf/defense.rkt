#lang racket
(require "driver.rkt")
(require "common.rkt")
(provide (all-defined-out)
         (all-from-out "common.rkt"))

(define make-robot (make-make-robot 'defense))

(define (load-laser) (bot-rpc #"load-laser" `()))
(define (shoot-laser) (bot-rpc #"shoot-laser" `()))
(define (laser-cooldown-left) (bot-rpc-num #"laser-cooldown-left" `()))
(define (opp-just-boosted?) (bot-rpc-bool #"just-boosted" `()))
(define (restock-laser) (bot-rpc #"restock-laser" '()))
(define (next-laser-power) (bot-rpc-num #"next-laser-power" '()))