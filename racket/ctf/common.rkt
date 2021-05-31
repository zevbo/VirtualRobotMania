#lang racket
(require "driver.rkt")
(require net/rfc6455)
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

(define-syntax-rule (our-service-mapper (main ...) [(image-name image) ...] [(file-name file) ...])
  (ws-service-mapper
   [file-name
    [(#f) ; if client did not request any subprotocol
     (lambda (c)
       (ws-send! c (file->bytes file)))]]
   ...
   
   [image-name
    [(#f) ; if client did not request any subprotocol
     (lambda (c)
       (define image-file (make-temporary-file "image-~a.png"))
       (save-image image image-file)
       (ws-send! c (file->bytes image-file))
       (delete-file image-file))]]
   ... 
   main
   ...))

(define (with-ws? run-internal)
  (define extra
    (with-output-to-string
      (lambda () (system "git rev-parse --show-prefix"))))
  (define depth (- (length (string-split extra "/")) 1))
  (define head (string-append (string-join (make-list depth "..") "/")))
  (define images-folder (string-append head "/images/"))
  (define game-server-js (string-append head "/ocaml/_build/game_server_js"))
  (define (run offense defense ws?)
    (cond
      [ws?
       (ws-serve*
        #:port 8080
        (our-service-mapper
         ([""
          [(#f)
           (lambda (conn s)
             ;(run-internal offense defense #:ws-conn conn)
             ; testing by just running it normally here
             (run-internal offense defense)
             )]]
          )
         [("/offense-bot" (robot-image offense)) ("/defense-bot" (robot-image defense))]
         [("/flag" (string-append images-folder "flag.png"))
          ("/flag-protector" (string-append images-folder "green-outline.bmp"))
          ("/index.html" (string-append game-server-js "index.html"))
          ("/main.bc.js" (string-append game-server-js "main.bc.js"))]
         ))
       (system "open --new -a \"Google Chrome\" --args \"http://localhost:8080\"")

       ]
      [else (run-internal offense defense)]))
  run)

(define run (with-ws? run-internal))
(define run-double (with-ws? run-double-internal))

(define degrees-mode degrees-mode-internal)
(define radians-mode radians-mode-internal)

