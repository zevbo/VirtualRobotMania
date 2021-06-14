#lang racket
(require racket/unix-socket)
(require racket/system)
(require csexp)
(require net/rfc6455)
(provide rpc build-ocaml)

(define (encode-length n)
  (bytes
   (bitwise-bit-field n 8 16)
   (bitwise-bit-field n 0 8)
   ))

(define (decode-length bytes)
  (+
   (arithmetic-shift (bytes-ref bytes 0) 8)
   (bytes-ref bytes 1)))

(define (rpc c message)
  (define w-bytes (csexp->bytes message))
  (printf "message encoded~n")
  (define w-length (encode-length (bytes-length w-bytes)))
  (ws-send! c (bytes-append w-length w-bytes) #:payload-type 'binary)
  (define raw-resp (ws-recv c #:payload-type 'binary))
  (printf "raw resp:~s~n" raw-resp)
  (define bytes (subbytes raw-resp 4))
  (bytes->csexp bytes))

(define (build-ocaml)
  (define cmd
    (string-append
     ;; Hack for Zev's machine, because, sigh.
     (if (equal? (system-type) 'macosx)
         "eval $(/usr/local/bin/opam env); "
         "eval $(opam env); ")
     "cd $(git rev-parse --show-toplevel)/ocaml; "
     "dune build @all"))
  (if (not (system cmd))
      (raise "Failed to build OCaml engine")
      '()))
