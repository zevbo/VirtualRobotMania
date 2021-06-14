#lang racket
(require "driver.rkt")
(require net/rfc6455)
(require csexp)
(require "../common/server-helper.rkt")

(require 2htdp/image)
(provide (all-defined-out))

(define (bot-rpc-ang msg args simple?)
  (of-radians (bot-rpc-num msg args simple?)))

(define (set-motors l r)
  (bot-rpc #"set-motors" `(,l ,r) #f))
(define (get-left-input) (bot-rpc-num #"l-input" '() #t))
(define (get-right-input) (bot-rpc-num #"r-input" '() #t))
(define (angle-to-opp) (bot-rpc-ang #"angle-to-opp" '() #t))
(define (dist-to-opp) (bot-rpc-num #"dist-to-opp" '() #t))
(define (angle-to-flag) (bot-rpc-ang #"angle-to-flag" '() #t))
(define (dist-to-flag) (bot-rpc-num #"dist-to-flag" '() #t))
(define (get-robot-angle) (bot-rpc-ang #"get-angle" '() #t))
(define (get-opp-angle) (bot-rpc-ang #"get-opp-angle" '() #t))
(define (looking-dist theta)
  (bot-rpc-num #"looking-dist" (to-radians theta) #f))
(define (offense-has-flag?) (bot-rpc-bool #"offense-has-flag" '() #t))
(define (offense-lives-left) (bot-rpc-num #"lives-left" '() #t))

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

(define (get-head)
  (define extra
    (with-output-to-string
      (lambda () (system "git rev-parse --show-prefix"))))
  (define depth (- (length (string-split extra "/")) 1))
  (string-append (string-join (make-list depth "..") "/")))

(define (with-ws? run-internal cached?)
  (define head (get-head))
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
       (define (entry name mime bytes)
         (cons name (cons mime bytes)))
       (define (file-entry name mime head path)
         (entry name mime (file->bytes (string-append head path))))
       (define (image-entry name image)
         (entry name PNG-MIME (image->bytes image)))
       (define index (file-entry "index.html" HTML-MIME game-files "index.html"))
       (define pages
         (make-hash
          (list
           (image-entry "offense-bot" (robot-image offense))
           (image-entry "defense-bot" (robot-image defense))
           (file-entry "boost-image" PNG-MIME images-folder "boost-fire.png")
           (file-entry "flag" PNG-MIME images-folder "flag.png")
           (file-entry "flag-protector" BMP-MIME images-folder "green-outline.bmp")
           (file-entry "main.bc.js" JS-MIME game-files "main.bc.js")
           index)))
       (cond
         [(file-exists? (string-append game-files "main.bc.runtime.js"))
          (printf "here~n")
          (define main-runtime-js
            (file-entry "main.bc.runtime.js" JS-MIME game-files "main.bc.runtime.js"))
          (hash-set! pages (car main-runtime-js) (cdr main-runtime-js))])
       (serve-website pages (cdr index) 8000)
       ]
      [else (run-internal offense defense)]
      )
    )
  run)

(define run (with-ws? run-internal #t))
;(define run-double (with-ws? run-double-internal #t))
(define run-dev (with-ws? run-internal #f))
;(define run-double-dev (with-ws? run-double-internal #f))

(define degrees-mode degrees-mode-internal)
(define radians-mode radians-mode-internal)
