#lang racket
(require 2htdp/image)
(require "../engine-connect.rkt")
(require "../robotVisualization.rkt")
(provide (all-defined-out))
(require csexp)

(struct robot (name kind on-tick image))

(define (make-make-robot kind)
  (lambda (name
           on-tick
           #:image-url   [image-url  OPTIONAL_DEFAULT]
           #:name-color  [name-color OPTIONAL_DEFAULT]
           #:name-font   [name-font  OPTIONAL_DEFAULT]
           #:name-style  [name-style OPTIONAL_DEFAULT]
           #:body-color  [body-color  'blue]
           #:wheel-color [wheel-color 'black])
    (define image
      (create-robot-img
       body-color wheel-color name
       #:custom-name-color name-color
       #:custom-name-font name-font
       #:custom-name-style name-style
       #:image-url image-url))
    (robot name kind on-tick image)))

(define (rpc-name robot)
  (match (robot-kind robot)
    ['offense #"Offense"]
    ['defense #"Defense"]))

(define (unknown-kind kind)
  (error "Your bot kind should be either 'offense or 'defense. This was neither" kind))

(define the-current-robot '())
(define the-connection '())
(define the-current-data '())

(define (step) (rpc the-connection `(#"step" ())))

(define (check-offense-defense offense defense)
  (match (robot-kind offense)
    ['offense '()]
    ['defense
     (error
      "You put a defense bot in the first spot, which is reserved for offense")]
    [other (unknown-kind other)])
  (match (robot-kind defense)
    ['defense '()]
    ['offense
     (error
      "You put an offense both in the second spot, which is reserved for defense")]
    [other (unknown-kind other)]))

(define dt_racket 0.12)
(define game-time 100)
(define total-ticks (floor (/ game-time dt_racket)))

(define (run-internal offense defense build? #:ws-conn [ws-conn #f])
  (check-offense-defense offense defense)
  (cond [build? (build-ocaml)])
  (set! the-connection ws-conn)
  (define tick-num 0)
  (define (loop)
    (set! the-current-robot offense)
    (set! the-current-data (get-simple-data tick-num))
    ((robot-on-tick offense) tick-num)
    (set! the-current-robot defense)
    (set! the-current-data (get-simple-data tick-num))
    ((robot-on-tick defense) tick-num)
    (set! the-current-robot '())
    (step)
    (set! tick-num (+ tick-num 1))
    (cond
      [(< tick-num total-ticks) (loop)]))
  (loop)
  (end-game))
(define start-wait-time 5)

(define (encode-number x)
  (string->bytes/utf-8 (number->string x)))

(define (decode-number b)
  (string->number (bytes->string/utf-8 b)))

(define (non-bot-rpc name arg)
  (rpc the-connection
       `(,name ,arg)))
(define (bot-rpc name arg simple?)
  (flush-output (current-output-port))
  (if simple?
      (hash-ref the-current-data name)
      (rpc the-connection
           `(,name (,(rpc-name the-current-robot) ,arg)))))

(define (bot-rpc-num name arg simple?)
  (decode-number (bot-rpc name arg simple?)))

(define (decode-bool b)
  (match (bytes->string/utf-8 b)
    ["true" #t]
    ["false" #f]
    [other #t]));(error "Expected true or false" other)]))

(define (bot-rpc-bool name arg simple?)
  (decode-bool (bot-rpc name arg simple?)))

(define (just-returned-flag?)
  (decode-bool (non-bot-rpc #"just-returned-flag" '())))
(define (just-killed?)
  (decode-bool (non-bot-rpc #"just-killed" '())))
(define (enhance-border)
  (non-bot-rpc #"enhance-border" '()))
(define (setup-shield)
  (non-bot-rpc #"setup-shield" '()))
(define (end-game) (rpc the-connection '(#"end-game" ())))
(define current-simple-data (void))

(define (get-simple-data tick#)
  (define csexp (bot-rpc #"get-simple-data" '() #f))
  (define bytes (csexp->bytes csexp))
  (define str (bytes->string/utf-8 bytes))
  (set! str (substring str 2 (- (string-length str) 2)))
  (define byte-datas (string-split str ")("))
  (define (byte-data->data byte-data)
    (define split (string-split byte-data ":"))
    (define len1 (string->number (first split)))
    (define key (string->bytes/utf-8 (string-replace (substring (second split) 0 len1) "_" "-")))
    (define value (string->bytes/utf-8 (third split)))
    (cons key value))
  (define all-data (make-immutable-hash (map byte-data->data byte-datas)))
  all-data)

(define degrees-over-radians (/ 180 pi))
(define x-over-radians degrees-over-radians)

(define (of-radians rad) (* rad x-over-radians))
(define (to-radians theta) (/ theta x-over-radians))

(define (degrees-mode-internal) (set! x-over-radians degrees-over-radians))
(define (radians-mode-internal) (set! x-over-radians 1))
