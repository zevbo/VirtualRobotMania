#lang racket
(require racket/unix-socket)
(require racket/system)
(require csexp)
(require net/rfc6455)
(provide
 (struct-out conn) rpc launch-and-connect-ws)

(define (encode-length n)
  (bytes
   (bitwise-bit-field n 8 16)
   (bitwise-bit-field n 0 8)
   ))

(define (decode-length bytes)
  (+
   (arithmetic-shift (bytes-ref bytes 0) 8)
   (bytes-ref bytes 1)))

(struct conn (r w) #:mutable)

(define (rpc c message)
  (define w-bytes (csexp->bytes message))
  (printf "writing message~n")
  (define w-length (encode-length (bytes-length w-bytes)))
  (printf "length: ~s ~s~n" (bytes-length w-bytes) w-length)
  (printf "MESSAGE: ~s~n" (bytes-append w-length w-bytes))
  (flush-output (current-output-port))
  (ws-send! (conn-w c) (bytes-append w-length w-bytes) #:payload-type 'binary)
  (printf "reading response~n")
  (flush-output (current-output-port))
  (define read-length (decode-length (read-bytes 2 (conn-r c))))
  (printf "length of response read~n")
  (flush-output (current-output-port))
  (define response (bytes->csexp (read-bytes read-length (conn-r c))))
  (printf "read response~n")
  (flush-output (current-output-port))
  response)

(define (get-conn pipename ws-conn)
  (cond
    [(ws-conn? ws-conn)
     (printf "getting connection~n")
     (flush-output (current-output-port))
     (define r (ws-recv-stream ws-conn))
     (printf "r gotten~n")
     (conn r ws-conn)]
    [else
     (define-values (r w) (unix-socket-connect pipename))
     (conn r w (lambda () (flush-output w) w))]))

(define (connect-loop pipename ws-conn)
  (with-handlers
    ([exn:fail? (lambda (exn) (sleep 0.1) (connect-loop pipename ws-conn))])
    (get-conn pipename ws-conn)))

(define (launch-and-connect-ws name ws-conn)
  (printf "launching and connecting~n")
  (flush-output (current-output-port))
  (define cmd
    (string-append
     ;; Hack for Zev's machine, because, sigh.
     (if (equal? (system-type) 'macosx)
         "eval $(/usr/local/bin/opam env); "
         "eval $(opam env); ")
     "cd $(git rev-parse --show-toplevel)/ocaml; "
     "dune build @all"))
  (process cmd)
  (connect-loop #false ws-conn))


;; How is this gonna work?
;; (for the dev version only for now)
;;
;; - First, run "dune build @all"
;; - Racket server needs to serve a bunch of "files", on some port (say, 8080)
;;    - index.html (from ocaml/_build/default/game_server_js/index.html)
;;    - main.bc.js (from ocaml/_build/default/game_server_js/main.bc.js)
;;    - one each for every image, i.e., offense.png, or whatever.
;; - Start chrome pointing at http://localhost:8080/index.html
;; - Chrome will load main.bc.js, and start the engine
;; - The racket program needs to open a websocket back in the other direction,
;;   and start firing csexp-rpc's at the engine. (Note, I probably screwed this up
;;   so that part doesn't work.)  NOTE: I called the protocol "csexp", i.e., the
;;   open websocket has the URL: "ws://localhost:8080/csexp".  I'm not sure how this
;;   really works.
;;
;; You might want to test the first part of this with the demo example, which is in:
;;   ocaml_build/geo_graph_js/test/ (both the main.bc.js and index.html).
;; You can't do the csexp-rpcs, but you can at least get the basic thing up and
;; running.
;;
;; Finally, note that I added new things to the protocol.  The new ones are called
;; things like set_flag_image_by_name, and the idea is you give it a name like
;; "flag.png", and then you'll get a request back to you (ordinary web request, not
;; web socket) to that name.  So you have to have those image names in what you're
;; serving up.
