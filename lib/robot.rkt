#lang racket
(require "robotVisualization.rkt")
(require "geo/geo.rkt")
(provide
 (struct-out robot) robot-point simple-bot
 set-inputs! set-pos! set-vels! change-inputs change-pos change-vel)

(define-syntax-rule (mutable-struct name (vars ...))
  (struct name ([vars #:mutable] ...)))
;; vl = left velocity, vr = right veloicty
(mutable-struct robot (image width length x y angle vl vr left% right% M))
(define (robot-point bot)
  (point (robot-x bot) (robot-y bot)))
(define DEFAULT_M 2500)
(define (simple-bot image)
  (robot image ROBOT_WIDTH ROBOT_LENGTH 0 0 0 0 0 0 0 DEFAULT_M))

(define (limit v minVal maxVal) (min maxVal (max minVal v)))
(define (limit-mag v max) (limit v (- 0 max) max))

(define (set-inputs! robot left% right% #:max [max 1])
  (set-robot-left%!  robot (limit-mag left%  max))
  (set-robot-right%! robot (limit-mag right% max)))
(define (change-inputs robot Δleft% Δright%)
  (set-inputs! robot (+ (robot-left% robot) Δleft%) (+ (robot-right% robot) Δright%)))
(define (set-pos! robot x y)
  (set-robot-x! robot x)
  (set-robot-y! robot y))
(define (change-pos robot Δx Δy)
  (set-pos! robot (+ (robot-x robot) Δx) (+ (robot-y robot) Δy)))
(define (set-vels! robot vl vr)
  (set-robot-vl! robot vl)
  (set-robot-vr! robot vr))
(define (change-vel robot Δvl Δvr)
  (set-vels! robot (+ (robot-vl robot) Δvl) (+ (robot-vr robot) Δvr)))