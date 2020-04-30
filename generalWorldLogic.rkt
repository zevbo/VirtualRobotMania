#lang racket
(require "robotVisualization.rkt")
(require 2htdp/image)
(provide set-inputs)

(define TICKS_PER_SECOND 20)
(define TICK_LENGTH (/ 1.0 TICKS_PER_SECOND))

(define-syntax-rule (mutable-struct name (vars ...))
  (struct name ([vars #:mutable] ...)))
;; vl = left velocity, vr = right veloicty
(mutable-struct robot (image x y angle vl vr left% right%))
(define (simple-bot image)
  (robot image 0 0 0 0 0 0 0))

(define (set-inputs robot left% right%)
  (set-robot-left%!  robot left%)
  (set-robot-right%! robot right%))

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

;; acceleration = M * %output - k * V
(define (get-acceleration m %output k v)
  (- (* m %output) (* k v)))
(define M 10) ;; arbitrary
(define VEL_ERROR 0.0001)
(define (update-pos robot #:dt [dt TICK_LENGTH])
  (define Δl (* dt (robot-vl robot)))
  (define Δr (* dt (robot-vr robot)))
  (cond
    [(< (abs (- Δl Δr)) VEL_ERROR) 
     (define Δx (* Δl (cos (robot-angle robot))))
     (define Δy (* Δl (sin (robot-angle robot))))
     (change-pos robot Δx Δy)]
    [else
     (define avgΔ (/ (+ Δl Δr) 2))
     ;; El math
     (define w (image-width (robot-image robot)))
     (define rad (/ (* w Δl) (- Δr Δl)))
     (define Δangle (/ Δl rad))
     (define old-angle (- (robot-angle robot) (/ pi 2)))
     (define new-angle (+ Δangle old-angle))
     ;; rm = radius from center of bot
     (define rm (+ rad (/ w 2)))
     (define Δx (* rm (- (cos new-angle) (cos old-angle))))
     (define Δy (* rm (- (sin new-angle) (sin old-angle))))
     (change-pos robot Δx Δy)
     (set-robot-angle! robot (+ (robot-angle robot) Δangle))]))
(define (update-vels robot k #:dt [dt TICK_LENGTH])
  (define Δvl (* dt (get-acceleration M (robot-left%  robot) k (robot-vl robot))))
  (define Δvr (* dt (get-acceleration M (robot-right% robot) k (robot-vr robot))))
  (change-vel robot Δvl Δvr))

(define my-robot-img 
(create-robot-img "magenta" "navy" "THE PELOSI MO-BEEL"
              #:custom-name-color "white"
              #:image-url "https://upload.wikimedia.org/wikipedia/commons/a/a5/Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg")
)(define my-bot (simple-bot my-robot-img))(set-inputs my-bot 3 4)
  