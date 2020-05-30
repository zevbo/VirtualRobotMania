#lang racket
(require "robot.rkt")
(require "helpers/edge-helpers.rkt")
(provide
 move-bot
 TICKS_PER_SECOND
 TICK_LENGTH)

(define TICKS_PER_SECOND 30) ;; anymore than 40 doesn't really do anything
(define TICK_LENGTH (/ 1.0 TICKS_PER_SECOND))

;; acceleration = M * %output - k * V
(define (get-acceleration m %output k v)
  (- (* m %output) (* k v)))
(define VEL_ERROR 0.0001)
(define DEFAULT_BOUNCE_SIZE 0.15)
(define (bounce robot #:bounciness [bounciness 1] #:bounce-size [bounce-size DEFAULT_BOUNCE_SIZE])
  (set-vels! robot (* -1 bounciness (robot-vl robot)) (* -1 bounciness (robot-vr robot)))
  (update-pos robot #:dt bounce-size)
  )
;; dt starts out as in ticks
(define (update-pos robot #:edges [edges (list)] #:bounce-size [bounce-size DEFAULT_BOUNCE_SIZE] #:dt [dt:ticks 1])
  (define dt (* dt:ticks TICK_LENGTH))
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
     (define w (robot-width robot))
     (define rad (/ (* w Δl) (- Δr Δl)))
     (define Δangle (/ Δl rad))
     (define old-angle (- (robot-angle robot) (/ pi 2)))
     (define new-angle (+ Δangle old-angle))
     ;; rm = radius from center of bot
     (define rm (+ rad (/ w 2)))
     (define Δx (* rm (- (cos new-angle) (cos old-angle))))
     (define Δy (* rm (- (sin new-angle) (sin old-angle))))
     (change-pos robot Δx Δy)
     (set-robot-angle! robot (+ (robot-angle robot) Δangle))])
  (cond
    [(map-robot-intersect? edges robot) 
     (bounce robot #:bounce-size bounce-size)])
  )
(define (update-vels robot k #:dt [dt:ticks 1])
  (define dt (* dt:ticks TICK_LENGTH))
  (define Δvl (* dt (get-acceleration (robot-M robot) (robot-left%  robot) k (robot-vl robot))))
  (define Δvr (* dt (get-acceleration (robot-M robot) (robot-right% robot) k (robot-vr robot))))
  (change-vel robot Δvl Δvr))
(define (move-bot robot k #:edges [edges (list)] #:dt [dt 1])
  (update-pos  robot #:edges edges #:dt dt)
  (update-vels robot k #:dt dt))

#|
(define my-robot-img 
(create-robot-img "magenta" "navy" "THE PELOSI MO-BEEL"
              #:custom-name-color "white"
              #:image-url "https://upload.wikimedia.org/wikipedia/commons/a/a5/Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg")
)(define my-bot (simple-bot my-robot-img))(set-inputs my-bot 3 4)
|#
  