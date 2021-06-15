#lang racket
(require "driver.rkt")
(require "common.rkt")
(provide (all-defined-out)
         (all-from-out "common.rkt"))

(define make-robot (make-make-robot 'offense))

(define (boost) (bot-rpc #"boost" `() #f))
(define (opp-just-fired?) (bot-rpc-bool #"just-fired" '() #t))
(define (boost-cooldown-left) (bot-rpc-num #"boost-cooldown-left" '() #t))