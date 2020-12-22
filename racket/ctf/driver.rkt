#lang racket
(require 2htdp/image)
(require "../engine-connect.rkt")
(require "../robotVisualization.rkt")
(provide all-defined-out)

(struct robot (name kind on-tick image))

(define (make-make-robot kind)
  (lambda (make-robot
           name
           kind
           on-tick
           #:image-url [image-url OPTIONAL_DEFAULT]
           #:image-url  [image-url  OPTIONAL_DEFAULT]
           #:name-color [name-color OPTIONAL_DEFAULT]
           #:name-font  [name-font  OPTIONAL_DEFAULT]
           #:name-style [name-style OPTIONAL_DEFAULT]
           #:body-color  [body-color  DEFAULT_BODY_COLOR]
           #:wheel-color [wheel-color DEFAULT_WHEEL_COLOR])
    (define robot-image
      (create-robot-img
       body-color wheel-color name
       #:custom-name-color name-color
       #:custom-name-font name-font
       #:custom-name-style name-style
       #:image-url image-url))
    (robot name on-tick image)))

(define (rpc-name robot)
  (match (robot-kind robot)
    (['offense #"Offense"]
     ['defense #"Defense"])))

(define (set-robot-image c robot)
  (define file (make-temporary-file "robot-~a.png"))
  (save-image (robot-image robot) file)
  (define msg `(#"set-image" (,(rpc-name robot) ,(path->bytes file))))
  (rpc c msg)
  (delete-file file))

(define (step c) (rpc c `(#"step" ())))

(define (unknown-kind kind)
  (error "Your bot kind should be either 'offense or 'defense. This was neither" kind))

(define the-current-robot '())

(define (query name arg)
  `(name (,(rpc-name the-current-robot) arg)))

(define (run offense defense)
  (match (robot-kind offense)
    (['offense '()]
     ['defense (error "You put a defense bot in the first spot, which is reserved for offense")]
     [other (unknown-kind other)]))
  (match (robot-kind defense)
    (['defense '()]
     ['offense (error "You put an offense both in the second spot, which is reserved for defense")]
     [other (unknown-kind other)]))
  (set! the-offense-robot offense)
  (set! the-defense-robot defense)
  (define c (launch-and-connect "ctf"))
  (define tick-num 0)
  (define (loop)
    (set! the-current-robot 'offense)
    ((robot-on-tick offense) tick-num)
    (set! the-current-robot 'defense)
    ((robot-on-tick defense) tick-num)
    (set! the-current-robot '())
    (step c)
    (loop))
  (loop))
