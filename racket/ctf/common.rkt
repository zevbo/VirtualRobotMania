#lang racket
(require "driver.rkt")
(provide (all-defined-out))

(define (bot-rpc-ang msg args)
  (of-radians (bot-rpc-num msg args)))

(define (set-motors l r)
  (bot-rpc #"set-motors" `(,l ,r)))
(define (get-left-input) (bot-rpc-num #"l-input" '()))
(define (get-right-input) (bot-rpc-num #"r-input" '()))
(define (angle-to-opp) (bot-rpc-ang #"angle-to-opp" '()))
(define (dist-to-opp) (bot-rpc-num #"dist-to-opp" '()))
(define (angle-to-flag) (bot-rpc-ang #"angle-to-flag" '()))
(define (dist-to-flag) (bot-rpc-num #"dist-to-flag" '()))
(define (get-robot-angle) (bot-rpc-ang #"get-angle" '()))
(define (get-opp-angle) (bot-rpc-ang #"get-opp-angle" '()))
(define (looking-dist theta)
  (bot-rpc-num #"looking-dist" (to-radians theta)))

(define degrees-mode degrees-mode-internal)
(define radians-mode radians-mode-internal)

(define run run-internal)
(define run-double run-double-internal)
