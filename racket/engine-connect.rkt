#lang racket
(require racket/unix-socket)
(require racket/system)
(require csexp)
(provide
 (struct-out conn) conn-close rpc launch-and-connect)

(define (encode-length n)
  (bytes
   (bitwise-bit-field n 8 16)
   (bitwise-bit-field n 0 8)
   ))

(define (decode-length bytes)
  (+
   (arithmetic-shift (bytes-ref bytes 0) 8)
   (bytes-ref bytes 1)))

(struct conn (r w))

(define (conn-close c)
  (close-output-port (conn-w c))
  (close-input-port (conn-r c)))

(define (rpc c message)
  (define w-bytes (csexp->bytes message))
  (define w-length (encode-length (bytes-length w-bytes)))
  (write-bytes w-length (conn-w c))
  (write-bytes w-bytes (conn-w c))
  (flush-output (conn-w c))
  (define read-length (decode-length (read-bytes 2 (conn-r c))))
  (bytes->csexp (read-bytes read-length (conn-r c))))

(define (connect-loop pipename)
  (with-handlers
    ([exn:fail? (lambda (exn) (sleep 0.1) (connect-loop pipename))])
    (define-values (r w) (unix-socket-connect pipename))
    (conn r w)))

(define (launch-and-connect name)
  (define pipename (path->string (make-temporary-file "game-~a.pipe")))
  (define cmd (string-append
               ;; Hack for Zev's machine, because, sigh.
               (if (equal? (system-type) 'macosx)
                   "eval $(/usr/local/bin/opam env); "
                   "eval $(opam env); ")
               "cd $(git rev-parse --show-toplevel)/ocaml; "
               "dune exec -- game_server/main.exe " name " " pipename))
  (process cmd)
  (connect-loop pipename))
