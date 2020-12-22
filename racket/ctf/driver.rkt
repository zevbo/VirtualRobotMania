#lang racket
(require 2htdp/image)
(require "../engine-connect.rkt")
(require "../robotVisualization.rkt")

(define (set-robot-image c defense? image file_path)
  (define file (make-temporary-file file_path))
  (println file)
  (save-image image file)
  (rpc c
       (if defense?
           `(#"set-defense-image"
           (,(path->bytes file)))
           `(#"set-offense-image"
           (,(path->bytes file)))))
  #;(delete-file file))
(define (set_defense_bot c path) (rpc c '("use_defense_bot" p)))
(define (set_offense_bot c path) (rpc c '("use_offense_bot" ())))
(define (step c) (rpc c `(#"step" ())))

(println (current-directory))
(println "About to connect")
(define c (launch-and-connect "ctf"))
(println "connected")

(define image (create-robot-img "blue" "black" "Cashuu 2.0"))
(define file "test-robot-~a.png")
(set-robot-image c #t image file)
(define (loop)
  (step c)
  (loop))
(loop)