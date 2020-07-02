#lang racket
(require 2htdp/image)
(require "worlds/chase-world/chase-world-base.rkt")
(save-image
 (create-robot-img "black" "blue" "cashuuu")
 "../rust-lib/test-robot.png")
 

(require ffi/unsafe ffi/unsafe/define)

(define-ffi-definer define-rust-mania
  (ffi-lib "../rust-lib/target/release/libracket_lib"))

(define-rust-mania fnurk (_fun -> _int32))

(fnurk)