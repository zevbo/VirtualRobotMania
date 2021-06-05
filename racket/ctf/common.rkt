#lang racket
(require "driver.rkt")
(require net/rfc6455)
(require "../common/server-helper.rkt")

(require 2htdp/image)
(provide (all-defined-out))

(define (bot-rpc-ang msg args)
  (of-radians (bot-rpc-num msg args)))

(define (set-motors l r)
  (bot-rpc #"set-motors" `(,l ,r)))
(define (get-left-input) (bot-rpc-num #"l-input" '()))
(define (get-right-input) (bot-rpc-num #"r-input" '()))
(define (angle-to-opp) (bot-rpc-ang #"angle-to-opp" '()))
(define (dist-to-opp) (bot-rpc-num #"dist-to-opp" '()))
(define (angle-to-flag) (bot-rpc-ang #"angle-to-flag" '()))
(define (dist-to-flag) (bot-rpc-num #"dist-to-flag" '()))
(define (get-robot-angle) (bot-rpc-ang #"get-angle" '()))
(define (get-opp-angle) (bot-rpc-ang #"get-opp-angle" '()))
(define (looking-dist theta)
  (bot-rpc-num #"looking-dist" (to-radians theta)))
(define (offense-has-flag?) (bot-rpc-bool #"offense-has-flag" '()))

(define (flmod x m)
  (- x (* (floor (/ x m)) m)))
(define (normalize-angle angle)
  (set! angle (to-radians angle))
  (define floored (inexact->exact (floor angle)))
  (of-radians (+ (- angle floored) (- (flmod (+ floored pi) (* 2 pi)) pi))))

(define (image->bytes image)
  (define image-file (make-temporary-file "image-~a.png"))
  (save-image image image-file)
  (define bytes (file->bytes image-file))
  (delete-file image-file)
  bytes)

(define (with-ws? run-internal cached?)
  (define extra
    (with-output-to-string
      (lambda () (system "git rev-parse --show-prefix"))))
  (define depth (- (length (string-split extra "/")) 1))
  (define head (string-append (string-join (make-list depth "..") "/")))
  (define images-folder (string-append head "/images/"))
  (define game-files
    (string-append head (if cached? "/ocaml/cached/" "/ocaml/_build/default/game_server_js/")))
  (define (run offense defense ws?)
    (cond
      [ws?
       (ws-serve
        #:port 8080
        (lambda (conn s)
          (run-internal offense defense (not cached?) #:ws-conn conn)
          ))
       (define JS-MIME #"text/javascript; charset=utf-8")
       (define HTML-MIME #"text/html; charset=utf-8")
       (define PNG-MIME #"image/png; charset=utf-8")
       (define BMP-MIME #"image/bmp; charset=utf-8")
       (define (game-file-bytes mime file)
         (cons mime (file->bytes (string-append game-files file))))
       (define index (game-file-bytes HTML-MIME "index.html"))
       (define main-js (game-file-bytes JS-MIME "main.bc.js"))
       (define use-runtime? (file-exists? (string-append game-files "main.bc.runtime.js")))
       (define main-runtime-js (if use-runtime? (game-file-bytes JS-MIME "main.bc.runtime.js") #f))
       (define pages
         (make-hash
          (list
           (cons "offense-bot" (cons PNG-MIME (image->bytes (robot-image offense))))
           (cons "defense-bot" (cons PNG-MIME (image->bytes (robot-image defense))))
           (cons "flag" (cons PNG-MIME (file->bytes (string-append images-folder "flag.png"))))
           (cons "flag-protector" (cons BMP-MIME (file->bytes (string-append images-folder "green-outline.bmp"))))
           (cons "index.html" index)
           (cons "main.bc.js" main-js))))
       (cond
         [use-runtime? (hash-set! pages "main.bc.runtime.js" main-runtime-js)])
       (serve-website pages index 8000)
       ]
      [else (run-internal offense defense)]
      )
    )
  run)

(define run (with-ws? run-internal #t))
(define run-double (with-ws? run-double-internal #t))
(define run-dev (with-ws? run-internal #f))
(define run-double-dev (with-ws? run-double-internal #f))

(define degrees-mode degrees-mode-internal)
(define radians-mode radians-mode-internal)
