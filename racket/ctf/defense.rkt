#lang racket
(require "driver.rkt")
(require "common.rkt")
(provide (all-defined-out)
         (all-from-out "common.rkt"))

(define make-robot (make-make-robot 'defense))

(define (shoot-laser) (bot-rpc #"shoot-laser" `()))
(define (laser-cooldown-left) (bot-rpc-num #"laser-cooldown-left" `()))
(define (opp-just-boosted?) (bot-rpc-bool #"just-boosted" `()))