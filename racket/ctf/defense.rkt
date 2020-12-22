#lang racket
(require "../engine-connect.rkt")
(require "driver.rkt")
(provide (all-defined-out))

(define make-robot (make-make-robot 'defense))

(define (set-motors l r)
  (bot-rpc #"set-motors" `(,l , r)))

(define (shoot-laser)
  (bot-rpc #"shoot-laser" `()))
