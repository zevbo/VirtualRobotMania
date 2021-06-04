#lang racket
(require web-server/servlet)
(require web-server/servlet-env)
(provide serve-website
         TEXT/JAVASCRIPT-MIME-TYPE)
(require net/rfc6455)
(require net/url)

;; Returns a HTTP response given a HTTP request.
(define (uri-extention request)
  (path/param-path (first (url-path (request-uri request)))))
(define req 0)
(define TEXT/JAVASCRIPT-MIME-TYPE #"text/javascript; charset=utf-8")
(define (gen-handler pages default)
  (define (request-handler request)
    (define val (if (hash-has-key? pages (uri-extention request))
                    (hash-ref pages (uri-extention request))
                    default))
    (define mime-type (car val))
    (define text (cdr val))
    (response/full
     200                  ; HTTP response code.
     #"OK"                ; HTTP response message.
     (current-seconds)    ; Timestamp.
     mime-type  ; MIME type for content.
     '()                  ; Additional HTTP headers.
     (list                ; Content (in bytes) to send to the browser.
      text)))
  request-handler
  )
(define (serve-website pages default port)
  (serve/servlet
   (gen-handler pages default)
   #:launch-browser? #t
   #:quit? #f
   #:listen-ip "127.0.0.1"
   #:port port
   #:servlet-path ""
   #:servlet-regexp #rx""))

;; Start the server.
