#lang racket
(require 2htdp/image)
(require "../engine-connect.rkt")
(require "../robotVisualization.rkt")
(provide (all-defined-out))

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

(define (set-robot-image c robot)
  (define file (make-temporary-file "robot-~a.png"))
  (save-image (robot-image robot) file)
  (define contents (file->bytes file))
  (define msg `(#"set-robot-image-contents" (,(rpc-name robot) ((#"contents" ,contents) (#"format" #"png")))))
  (rpc c msg)
  (delete-file file)
  )

(define (set-image c protector?)
  (define extra
    (with-output-to-string
      (lambda () (system "git rev-parse --show-prefix"))))
  (define depth (- (length (string-split extra "/")) 1))
  (define image-name (if protector? "green-outline.bmp" "flag.png"))
  (define format (if protector? #"bmp" #"png"))
  (define file (string-append (string-join (make-list depth "..") "/") "/images/" image-name))
  (define contents (file->bytes file))
  (define command-name (if protector? #"set-flag-protector-image-contents" #"set-flag-image-contents"))
  (define msg `(,command-name ((#"contents" ,contents) (#"format" ,format))))
  (rpc c msg))

(define (unknown-kind kind)
  (error "Your bot kind should be either 'offense or 'defense. This was neither" kind))

(define the-current-robot '())
(define the-connection '())

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

(define (startup offense defense #:ws-conn [ws-conn #f])
  (check-offense-defense offense defense)
  (set! the-connection (launch-and-connect "ctf" #:ws-conn ws-conn))
  (set-image the-connection #f)
  (set-image the-connection #t)
  (set-robot-image the-connection offense)
  (set-robot-image the-connection defense)
  
  the-connection)
(define (run-internal offense defense #:ws-conn [ws-conn #f])
  (set! the-connection (startup offense defense #:ws-conn ws-conn))
  (define tick-num 0)
  (define (loop)
    (set! the-current-robot offense)
    ((robot-on-tick offense) tick-num)
    (set! the-current-robot defense)
    ((robot-on-tick defense) tick-num)
    (set! the-current-robot '())
    (step)
    (set! tick-num (+ tick-num 1))
    (loop))
  (loop))
(define start-wait-time 5)
(define (run-double-internal off1 def1 off2 def2 #:ws-conn [ws-conn #f])
  (check-offense-defense off1 def1)
  (check-offense-defense off2 def2)
  (define conn1 (startup off1 def1))
  (define conn2 (startup off2 def2))
  (define tick-num 0)
  (define (tick)
    (define (run-game c other-c off def)
      (set! the-connection c)
      (set! the-current-robot off)
      ((robot-on-tick off) tick-num)
      (set! the-current-robot def)
      ((robot-on-tick def) tick-num)
      (set! the-current-robot '())
      (cond
        [(just-killed?)
         (set! the-connection other-c)
         (setup-shield)]
        [(set! the-connection other-c)
         (enhance-border)])
      (step))
    (run-game conn1 conn2 off1 def1 #:ws-conn ws-conn)
    (run-game conn2 conn1 off2 def2 #:ws-conn ws-conn)
    (set! tick-num (+ tick-num 1)))
  (tick)
  (sleep start-wait-time)
  (define (loop)
    (tick)
    (loop))
  (loop))

(define (encode-number x)
  (string->bytes/utf-8 (number->string x)))

(define (decode-number b)
  (string->number (bytes->string/utf-8 b)))

(define (non-bot-rpc name arg)
  (rpc the-connection
       `(,name ,arg)))
(define (bot-rpc name arg)
  (rpc the-connection
       `(,name (,(rpc-name the-current-robot) ,arg))))

(define (bot-rpc-num name arg)
  (decode-number (bot-rpc name arg)))

(define (decode-bool b)
  (match (bytes->string/utf-8 b)
    ["true" #t]
    ["false" #f]
    [other (error "Expected true or false" other)]))

(define (bot-rpc-bool name arg)
  (decode-bool (bot-rpc name arg)))

(define (just-returned-flag?)
  (decode-bool (non-bot-rpc #"just-returned-flag" '())))
(define (just-killed?)
  (decode-bool (non-bot-rpc #"just-killed" '())))
(define (enhance-border)
  (non-bot-rpc #"enhance-border" '()))
(define (setup-shield)
  (non-bot-rpc #"setup-shield" '()))

(define degrees-over-radians (/ 180 pi))
(define x-over-radians degrees-over-radians)

(define (of-radians rad) (* rad x-over-radians))
(define (to-radians theta) (/ theta x-over-radians))

(define (degrees-mode-internal) (set! x-over-radians degrees-over-radians))
(define (radians-mode-internal) (set! x-over-radians 1))
