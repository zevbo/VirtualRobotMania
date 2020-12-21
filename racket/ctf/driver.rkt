#lang racket
;(require 2htdp/image)
(require "../engine-connect.rkt")
;(require "../robotVisualization.rkt")

(define c (launch-and-connect "ctf"))
(define (use_defense_bot) (rpc c "use_defense_bot"))