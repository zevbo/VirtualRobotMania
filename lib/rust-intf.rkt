#lang racket
(require ffi/unsafe ffi/unsafe/define)

(define-ffi-definer define-rust-mania
  (ffi-lib "../rust-lib/target/release/librust_mania"))

(define-rust-mania fnurk (_fun _int32 _int32 -> _int32))

(fnurk 3 4)