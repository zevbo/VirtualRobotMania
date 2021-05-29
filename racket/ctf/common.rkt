#lang racket
(require "driver.rkt")
(require net/rfc6455)
(provide (all-defined-out))

(define degrees-over-radians (/ 180 pi))
(define (bot-rpc-ang msg args)
  (* degrees-over-radians (bot-rpc-num msg args)))

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
  (bot-rpc-num #"looking-dist" (/ theta degrees-over-radians)))
(define (offense-has-flag?) (bot-rpc-bool #"offense-has-flag" '()))

(define (normalize-angle angle)
  (define floored (inexact->exact (floor angle)))
  (+ (- angle floored) (- (modulo (+ floored 180) 360) 180)))

(define (with-ws? run-internal)
  (define (run offense defense ws?)
    (cond
      [ws?
       (ws-serve
        #:port 8080
        (lambda (conn s)
          ;(run-internal offense defense #:ws-conn conn)
          ; testing by just running it normally here
          (run-internal offense defense)
          ))]
      [else (run-internal offense defense)]))
  run)

(define run (with-ws? run-internal))
(define run-double (with-ws? run-double-internal))


