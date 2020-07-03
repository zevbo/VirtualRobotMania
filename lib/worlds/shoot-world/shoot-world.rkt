#lang racket
(require "shoot-world-base.rkt")
(provide
 run make-robot set-world!
 set-motors! shoot angle-to-other-bot dist-to-other-bot
 set-radian-mode set-degree-mode get-cooldown-time
 get-looking-dist get-lookahead-dist get-lookbehind-dist num-balls-left
 front-left-close? front-right-close? back-left-close? back-right-close?
 normalize-angle angles-to-neutral-balls)

 (define-syntax-rule (make-robot args ...)
    (internal-make-robot 'normal args ...))