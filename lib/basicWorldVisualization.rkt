#lang racket
(require "baseWorldLogic.rkt")
(require "robotVisualization.rkt")
(require "robot.rkt")
(require (prefix-in G- "geo/geo.rkt"))
(require 2htdp/image)
(require racket/date)
(require 2htdp/universe)
(provide create-blank-canvas create-walled-canvas
         create-robot-img
         (struct-out robot)
         simple-bot
         overlay-robot overlay-image
         create-run-function)

(define (create-blank-canvas width height)
  (rectangle width height "outline" "black"))
(define (overlay-line-seg canvas line-seg color)
  (define diff (G-sub-points (G-line-seg-p1 line-seg) (G-line-seg-p2 line-seg)))
  (define mid-point (G-mid-point (G-line-seg-p1 line-seg) (G-line-seg-p2 line-seg)))
  (overlay/offset
   (line (G-point-x diff) (- 0 (G-point-y diff)) color)
   (- 0 (G-point-x mid-point)) (G-point-y mid-point)
   canvas))
(define (create-walled-canvas width height edges #:edge-color [edge-color "black"])
  (foldl
   (lambda (edge canvas) (overlay-line-seg canvas edge edge-color))
   (rectangle width height "solid" "white") edges))

(define (overlay-image canvas image angle pos)
  (overlay/offset
   (rotate (radians->degrees angle) image)
   (- 0 (G-point-x pos)) (G-point-y pos)
   canvas))
(define (overlay-robot canvas bot)
  (overlay-image canvas (robot-image bot) (robot-angle bot) (robot-point bot)))

(define my-bot-image (create-robot-img "magenta" "navy" "THE PELOSI MO-BEEL"
                                       #:custom-name-color "white"))
(define my-bot (simple-bot my-bot-image))
(set-inputs! my-bot 0.2 1)

;; every game must have a world
;; on-tick takes an argument for the world
(define (print-times f og)
  (lambda (arg)
    (printf "starting draw:~s~n" (- (current-milliseconds) og))
    (define v (f arg))
    (printf "ending draw:~s~n~n" (- (current-milliseconds) og))
    v))
(define-syntax-rule (create-run-function run-func [body-initialize ...] to-draw-f get-world-f
                                         [body-start ...] [body-end ...] stop-f [function-end ...])
  (begin
    (define tick# 0)
    (define (run-func on-tick-f)
      body-initialize ...
      (big-bang (get-world-f)
        [to-draw to-draw-f]
        [stop-when stop-f]
        [on-tick
         (lambda (world) body-start ... (on-tick-f tick#) body-end ...
           (set! tick# (+ tick# 1)) world)
         TICK_LENGTH])
      function-end ...)))