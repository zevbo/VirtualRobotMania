#lang racket
(require "../robot.rkt")
(require "canvas-edges.rkt")

(define (robot-edges robot)
  (define-values (top bot right left)
    (get-edges (robot-width robot) (robot-height robot)))
  (

;; eventually must be corrected to use line-segments
(define (map-intersection? robot edges)
  (