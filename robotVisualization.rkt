#lang racket
(require 2htdp/image)
(provide create-robot-img
         ROBOT_WIDTH ROBOT_LENGTH
         OPTIONAL_DEFAULT)

(define ROBOT_WIDTH 60.0)

(define (rounded-rectangle width height pen-type color rounded-radius)
  (define (add-edge body st-bot? st-right?)
    ;; st = starting spot
    ;; en = ending spot
    ;; lines made in clock-wise fashion
    (define ed-bot? st-right?)
    (define ed-right? (not st-bot?))
    (scene+line
     body
     (if st-right? (- width  rounded-radius) rounded-radius)
     (if st-bot?   (- height rounded-radius) rounded-radius)
     (if ed-right? (- width  rounded-radius) rounded-radius)
     (if ed-bot?   (- height rounded-radius) rounded-radius)
     (make-pen color rounded-radius pen-type "round" "round")))
  (define hit-box (rectangle width height "solid" "transparent"))
  (define outline
   (add-edge
    (add-edge
     (add-edge
      (add-edge
       hit-box
       #t #t)
      #t #f)
     #f #t)
    #f #f))
  (if (equal? pen-type "solid")
      (underlay
       (rectangle (- width  (* rounded-radius 2))
                  (- height (* rounded-radius 2))
                  "solid" color)
       outline)
      outline))
              
(define OPTIONAL_DEFAULT 'DEFAULT) ;; signals to choose what would be the default
(define-syntax-rule (->default! var default) ;; Needs better name
  (cond
    [(equal? var OPTIONAL_DEFAULT) (set! var default)]))

(define ROBOT_L/W 1.5)
(define ROBOT_LENGTH (* ROBOT_WIDTH ROBOT_L/W))
(define WHEEL_RADIUS (* ROBOT_WIDTH .16))
(define WHEEL_DISTANCE_CONSTANT 0.6)
(define WHEEL_WIDTH_CONSTANT 0.8)
(define CORNER_RADIUS (floor (/ ROBOT_WIDTH 10)))
(define IDEAL_IMAGE_WIDTH  (/ ROBOT_WIDTH 2))
(define IDEAL_IMAGE_HEIGHT (/ ROBOT_LENGTH 2))
(define VERTICAL_IMAGE_PLACEMENT -0.2) ;; percentage up from center
(define MAX_IMAGE_WIDTH  ROBOT_WIDTH)
(define MAX_IMAGE_HEIGHT (* ROBOT_LENGTH 0.65))
(define NAME_PLACEMENT 0.5) ;; percentage up from center
(define NAME_FONT_SIZE (floor (/ ROBOT_WIDTH 8.0)))
(define DEFAULT_NAME_FONT "modern")
(define DEFAULT_NAME_COLOR "black")
(define DEFAULT_NAME_STYLE 'normal)
(define MAX_NAME_WIDTH (* ROBOT_WIDTH .85))
(define NO_IMAGE "N/A")
(define (add-image robot image-url)
  (cond
    [(equal? image-url NO_IMAGE) robot]
    [else
     (begin
       (define img (bitmap/url image-url))
       (define ideal-width-c  (/ IDEAL_IMAGE_WIDTH  (image-width  img)))
       (define ideal-height-c (/ IDEAL_IMAGE_HEIGHT (image-height img)))
       (define ideal-c (/ (+ ideal-width-c ideal-height-c) 2))
       (define worst-width-c  (/ MAX_IMAGE_WIDTH  (image-width img)))
       (define worst-height-c (/ MAX_IMAGE_HEIGHT (image-width img)))
       (overlay/offset
        (scale
         (min worst-width-c worst-height-c ideal-c)
         img)
        0 (* VERTICAL_IMAGE_PLACEMENT ROBOT_LENGTH)
        robot))]))

(define (multiply-str str n)
  (string-join (build-list n (lambda (_) str)) ""))


(define (append-images-horizontally . images)
  (set! images (flatten images))
  (foldr
   (λ (image1 image2)
     (overlay/offset
      image1 (/ (+ (image-width image1) (image-width image2)) 2) 0 image2))
   empty-image images))
(define (append-images-vertically . images)
  (set! images (flatten images))
  (foldr
   (λ (image1 image2)
     (overlay/align/offset
      "left" "center"
      image1 0 (/ (+ (image-height image1) (image-height image2)) 2) image2))
   empty-image images))

(define-syntax-rule (centered-text/font max-width text args ...)
  (begin
    (define trimmed-text (string-trim text))
    (define text-image (text/font trimmed-text args ...))
    (define text-height (image-height text-image))
    (overlay
     text-image
     (rectangle max-width text-height "solid" "transparent"))))

;; get's one line that fits in max-width
(define (get-one-line max-width text rest-of-words
                      font-size color face family style weight underline)
  (cond
    [(empty? rest-of-words) (values text rest-of-words)]
    [else
     (define test-text (string-append text " " (first rest-of-words)))
     (define test-image
       (text/font test-text font-size color face family style weight underline))
     (if (> (image-width test-image) max-width)
         (values text rest-of-words)
         (get-one-line
          max-width test-text (cdr rest-of-words)
          font-size color face family style weight underline))]))

(define (get-lines max-width words
                   font-size color face family style weight underline)
  (cond
    [(empty? words) (list)]
    [else
     (define-values
       (line rest-of-words)
       (get-one-line max-width "" words
                   font-size color face family style weight underline))
      (cons line
            (get-lines max-width rest-of-words
                   font-size color face family style weight underline))]))
   
(define (centered-and-indented max-width text
                               font-size color face family style weight underline)
  (append-images-vertically
   (map (lambda (text)
          (centered-text/font max-width text
                              font-size color face family style weight underline))
        (get-lines max-width (string-split text " ")
                   font-size color face family style weight underline))))
    

(define (add-name robot name color font style)
  (overlay/offset
   (centered-and-indented MAX_NAME_WIDTH name NAME_FONT_SIZE color #f font style 'bold #f)
   0
   (* NAME_PLACEMENT (/ ROBOT_LENGTH 2))
   robot))

(define (create-robot-img body-color wheel-color robot-name
                      #:custom-name-font [font OPTIONAL_DEFAULT]
                      #:custom-name-color [color OPTIONAL_DEFAULT]
                      #:custom-name-style [style OPTIONAL_DEFAULT]
                      #:image-url [image-url OPTIONAL_DEFAULT])
  (->default! font DEFAULT_NAME_FONT)
  (->default! color DEFAULT_NAME_COLOR)
  (->default! style DEFAULT_NAME_STYLE)
  (->default! image-url NO_IMAGE)
  (define (add-wheel body bottom? right?)
    (underlay/offset
     (circle WHEEL_RADIUS "solid" wheel-color)
     (* (if right?  1 -1) (* (/ ROBOT_WIDTH 2)  WHEEL_WIDTH_CONSTANT))
     (* (if bottom? 1 -1) (* (/ ROBOT_LENGTH 2) WHEEL_DISTANCE_CONSTANT))
     body)
    )
  (define center
    (underlay
     (rectangle (+ (* 2 WHEEL_RADIUS) (* WHEEL_WIDTH_CONSTANT ROBOT_WIDTH)) ROBOT_LENGTH "solid" "transparent")
     (rounded-rectangle ROBOT_WIDTH ROBOT_LENGTH "solid" body-color CORNER_RADIUS)))
  (define
    robot
    (add-wheel
     (add-wheel
      (add-wheel
       (add-wheel
        center
        #t #t)
       #t #f)
      #f #t)
     #f #f))
   (rotate
    -90
    (add-name
     (add-image robot image-url)
     robot-name color font style)))

#| 
;Examle:
(create-robot-img "magenta" "navy" "THE PELOSI MO-BEEL"
              #:custom-name-color "white"
              #:image-url "https://upload.wikimedia.org/wikipedia/commons/a/a5/Official_photo_of_Speaker_Nancy_Pelosi_in_2019.jpg")

;|#