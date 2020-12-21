#lang racket
(require 2htdp/image)
(require "../engine-connect.rkt")
;(require "../robotVisualization.rkt")

(define (use_defense_bot c) (rpc c "use_defense_bot"))
(define (use_offense_bot c) (rpc c "use_offense_bot"))
(define (step c) (rpc c "step"))

(println (current-directory))
(println "About to connect")
(define c (launch-and-connect "test"))
(println "connected")

(define (loop)
  (println "step")
  (step c)
  (loop))
(loop)