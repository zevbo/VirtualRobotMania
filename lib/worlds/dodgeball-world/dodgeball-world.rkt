#lang racket
(require "dodgeball-world-base.rkt")
(provide
 run make-robot set-world!
 set-motors! change-motor-inputs shoot angle-to-other-bot dist-to-other-bot
 set-radian-mode set-degree-mode get-cooldown-time
 get-left% get-right% get-robot-angle get-vl get-vr
 get-looking-dist get-lookahead-dist get-lookbehind-dist num-balls-left
 front-left-close? front-right-close? back-left-close? back-right-close?
 relative-angle-of-other-bot level-diffs
 robot-width robot-length get-ball-vi
 normalize-angle angles-to-neutral-balls other-bot-shooting? other-bot-level)

 (define-syntax-rule (make-robot args ...)
    (internal-make-robot 'normal args ...))