#lang racket
(require racket/unix-socket)
(require racket/system)
(require csexp)
(require net/rfc6455)
(provide
 (struct-out conn) conn-close rpc launch-and-connect launch-and-connect-ws)

(define (encode-length n)
  (bytes
   (bitwise-bit-field n 8 16)
   (bitwise-bit-field n 0 8)
   ))

(define (decode-length bytes)
  (+
   (arithmetic-shift (bytes-ref bytes 0) 8)
   (bytes-ref bytes 1)))

(struct conn (r w flush))

(define (conn-close c)
  (close-output-port (conn-w c))
  (close-input-port (conn-r c)))

(define (rpc c message)
  (define w-bytes (csexp->bytes message))
  (printf "writing message~n")
  (define w-length (encode-length (bytes-length w-bytes)))
  (write-bytes w-length (conn-w c))
  (write-bytes w-bytes (conn-w c))
  (printf "flushing message~n")
  ((conn-flush c))
  (printf "reading response~n")
  (define read-length (decode-length (read-bytes 2 (conn-r c))))
  (define response (bytes->csexp (read-bytes read-length (conn-r c))))
  (printf "read response~n")
  response)

(define (get-conn pipename ws-conn)
  (cond
    [(ws-conn? ws-conn)
     (printf "getting connection~n")
     (define r (ws-recv-stream ws-conn))
     (printf "r gotten~n")
     (define-values (in out) (make-pipe))
     (printf "pipe made~n")
     (conn r out (lambda () (ws-send! ws-conn in #:payload-type 'binary)))]
    [else
     (define-values (r w) (unix-socket-connect pipename))
     (conn r w (lambda () (flush-output w)))]))

(define (connect-loop pipename ws-conn)
  (with-handlers
    ([exn:fail? (lambda (exn) (sleep 0.1) (connect-loop pipename ws-conn))])
    (get-conn pipename ws-conn)))

(define (launch-and-connect name)
  (define pipename (path->string (make-temporary-file "game-~a.pipe")))
  (define cmd
    (string-append
     ;; Hack for Zev's machine, because, sigh.
     (if (equal? (system-type) 'macosx)
         "eval $(/usr/local/bin/opam env); "
         "eval $(opam env); ")
     "cd $(git rev-parse --show-toplevel)/ocaml; "
     "dune exec -- game_server/main.exe " name " " pipename))
  ;; For new, javascript world, maybe just do "dune build @all"
  (process cmd)
  (connect-loop pipename #false))
(define (launch-and-connect-ws name ws-conn)
  (printf "launching and connecting")
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
