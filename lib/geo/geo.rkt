#lang racket

(define DELTA 1)
(define EPSILON 0.0001)


;                                                    
;                                                    
;                                                    
;                           ;;                       
;   ;;;;;;                  ;;                 ;;    
;   ;;   ;;                                    ;;    
;   ;;    ;;                                   ;;    
;   ;;    ;;    ;;;;      ;;;;    ;; ;;;;    ;;;;;;; 
;   ;;    ;;   ;;  ;;       ;;    ;;;  ;;;     ;;    
;   ;;   ;;   ;;    ;;      ;;    ;;    ;;     ;;    
;   ;;;;;;    ;;    ;;      ;;    ;;    ;;     ;;    
;   ;;        ;;    ;;      ;;    ;;    ;;     ;;    
;   ;;        ;;    ;;      ;;    ;;    ;;     ;;    
;   ;;        ;;    ;;      ;;    ;;    ;;     ;;    
;   ;;         ;;  ;;       ;;    ;;    ;;     ;;    
;   ;;          ;;;;     ;;;;;;;; ;;    ;;      ;;;; 
;                                                    
;                                                    
;                                                    
;                                                    
(provide (struct-out point))

(struct point (x y) #:transparent)

;                                                                                  
;                                                                                  
;                                                                                  
;                 ;;                                      ;;    ;;                 
;   ;;            ;;                        ;;            ;;    ;;                 
;   ;;                                      ;;                  ;;                 
;   ;;                                      ;;                  ;;                 
;   ;;          ;;;;    ;; ;;;;     ;;;;;   ;;          ;;;;    ;;   ;;;    ;;;;;  
;   ;;            ;;    ;;;  ;;;   ;;   ;;  ;;            ;;    ;;  ;;;    ;;   ;; 
;   ;;            ;;    ;;    ;;  ;;     ;  ;;            ;;    ;; ;;;    ;;     ; 
;   ;;            ;;    ;;    ;;  ;;;;;;;;; ;;            ;;    ;;;;;     ;;;;;;;;;
;   ;;            ;;    ;;    ;;  ;;        ;;            ;;    ;;;;;     ;;       
;   ;;            ;;    ;;    ;;  ;;        ;;            ;;    ;;;;;;    ;;       
;   ;;            ;;    ;;    ;;  ;;        ;;            ;;    ;;  ;;    ;;       
;   ;;            ;;    ;;    ;;   ;;    ;  ;;            ;;    ;;   ;;    ;;    ; 
;   ;;;;;;;;   ;;;;;;;; ;;    ;;     ;;;;;  ;;;;;;;;   ;;;;;;;; ;;   ;;;     ;;;;; 
;                                                                                  
;                                                                                  
;
(provide (struct-out line) (struct-out line-seg) (struct-out ray)
         get-p1 get-p2 to-line collinear? on-ll?)

(struct line (p1 p2) #:transparent)
(struct line-seg (p1 p2) #:transparent)
(struct ray (p-end p-dir) #:transparent)

(define (get-p1 ll) (line-p1 (to-line ll)))
(define (get-p2 ll) (line-p2 (to-line ll)))

(define (constructor-of-ll ll)
  (match ll
    [(line _0 _1) line]
    [(line-seg _0 _1) line-seg]
    [(ray _0 _1) ray]))
    
(define (to-line ll)
  (match ll
    [(line p1 p2) (line p1 p2)]
    [(line-seg p1 p2) (line p1 p2)]
    [(ray p-end p-dir) (line p-end p-dir)]))

(define (collinear? p1 p2 p3)
  (< (abs (- (* (- (point-y p2) (point-y p1)) (- (point-x p3) (point-x p2)))
             (* (- (point-x p2) (point-x p1)) (- (point-y p3) (point-y p2))))) EPSILON))
(define (on-line? l p)
  (collinear? (line-p1 l) (line-p2 l) p))

(define (on-ll? ll p)
  (and
   (on-line? (to-line ll) p)
   (match ll
     [(line p1 p2) #t]
     [(line-seg p1 p2)
       (begin
         (define diffs (cons (sub-points p1 p) (sub-points p2 p)))
         (and (<= (* (point-x (car diffs)) (point-x (cdr diffs))) EPSILON)
              (<= (* (point-y (car diffs)) (point-y (cdr diffs))) EPSILON)))]
     [(ray p-end p-dir)
      (begin
       (define dir-p (sub-points p p-end))
       (define dir-real (sub-points p-dir p-end))
       (or (> (* (point-x dir-p) (point-x dir-real)) (- 0 EPSILON))
           (> (* (point-y dir-p) (point-y dir-real)) (- 0 EPSILON))
           (equal? p p-end)))])))


;                                                                        
;                                                                        
;                                                                        
;                                                                ;;;;    
;      ;;;;                                                        ;;    
;    ;;;   ;                                                       ;;    
;    ;;                                                            ;;    
;   ;;          ;;;;;   ;; ;;;;     ;;;;;     ;;  ;;    ;;;;;      ;;    
;   ;;         ;;   ;;  ;;;  ;;;   ;;   ;;    ;;;;  ;  ;    ;;     ;;    
;   ;;        ;;     ;  ;;    ;;  ;;     ;    ;;;           ;;     ;;    
;   ;;  ;;;;  ;;;;;;;;; ;;    ;;  ;;;;;;;;;   ;;        ;;;;;;     ;;    
;   ;;    ;;  ;;        ;;    ;;  ;;          ;;      ;;;   ;;     ;;    
;   ;;    ;;  ;;        ;;    ;;  ;;          ;;      ;;    ;;     ;;    
;    ;;   ;;  ;;        ;;    ;;  ;;          ;;      ;;    ;;     ;;    
;    ;;   ;;   ;;    ;  ;;    ;;   ;;    ;    ;;      ;;   ;;;     ;;    
;      ;;;;      ;;;;;  ;;    ;;     ;;;;;    ;;       ;;;; ;;      ;;;; 
;                                                                        
;                                                                        
;                                                                        
;                                                                        


(provide point-slope-form point-angle-form
         intersection intersect?
         add-points sub-points scale-point rotate-point mid-point
         add-p-to-ll rotate-ll
         dist distSq
         slope-of angle-of parallel?
         ray-point-angle-form
         angle-between
         normalize-angle:rad normalize-angle:deg)


(define (normalize-angle:deg angle)
  (define int-angle (floor angle))
  (define norm-int-angle (- (modulo (+ int-angle 180) 360) 180))
  (define real-angle (+ norm-int-angle (- angle (floor angle))))
  (if (> real-angle 180)
      (- real-angle 360)
      real-angle))
(define (normalize-angle:rad angle)
  (degrees->radians (normalize-angle:deg (radians->degrees angle))))

(define (point-slope-form p slope)
  (line p (point (+ (point-x p) DELTA) (+ (point-y p) (* DELTA slope)))))
(define (point-angle-form p angle)
  (if (= angle (/ pi 2))
      (line p (point (point-x p) (+ (point-y p) DELTA)))
      (point-slope-form p (tan angle))))
(define (ray-point-angle-form p angle)
  (ray p (point (+ (point-x p) (* DELTA (cos angle)))
                (+ (point-y p) (* DELTA (sin angle))))))

(define (add-points p1 p2)
  (point (+ (point-x p1) (point-x p2))
         (+ (point-y p1) (point-y p2))))
(define (sub-points p1 p2)
  (add-points p1 (scale-point -1 p2)))
(define (scale-point c p)
  (point (* c (point-x p))
         (* c (point-y p))))
(define (rotate-point p theta)
  (point (- (* (point-x p) (cos theta)) (* (point-y p) (sin theta)))
         (+ (* (point-x p) (sin theta)) (* (point-y p) (cos theta)))))
(define (mid-point . points)
  (scale-point (/ 1 (length points)) (foldl add-points (point 0 0) points)))

(define (transform-ll f ll)
  ((constructor-of-ll ll) (f (get-p1 ll)) (f (get-p2 ll))))
(define (add-p-to-ll ll p)
  (transform-ll (lambda (p0) (add-points p0 p)) ll))
(define (rotate-ll ll theta)
  (transform-ll (lambda (p) (rotate-point p theta)) ll))

(define (angle-between p1 p2)
  (atan (- (point-y p2) (point-y p1))
        (- (point-x p2) (point-x p1))))

(define (slope-of ll)
  (define diff (sub-points (get-p1 ll) (get-p2 ll)))
  (/ (point-y diff) (point-x diff)))
(define (angle-of ll)
  (cond
    [(= (point-x (get-p1 ll)) (point-x (get-p2 ll))) (/ pi 2)]
    [(atan (slope-of ll))]))
(define (parallel? ll1 ll2)
  (= (angle-of ll1) (angle-of ll2)))

(define (intersection ll1 ll2 #:empty-value [empty-value (void)])
  ;; Algorithim: http://geomalgorithms.com/a05-_intersect-1.html
  (cond
    [(parallel? ll1 ll2) empty-value]
    [else
     (define u (sub-points (get-p2 ll1) (get-p1 ll1)))
     (define v (sub-points (get-p2 ll2) (get-p1 ll2)))
     (define w (sub-points (get-p1 ll1) (get-p1 ll2)))
     ; (v.y * w.x - v.x * w.y) / (v.x * u.y - v.y * u.x);
     (define s (/
                (- (* (point-y v) (point-x w)) (* (point-x v) (point-y w)))
                (- (* (point-x v) (point-y u)) (* (point-y v) (point-x u)))))
     (define p (add-points (get-p1 ll1) (scale-point s u)))
     (if (and (on-ll? ll1 p) (on-ll? ll2 p))
         p
         empty-value)]))
(define (intersect? ll1 ll2)
  (not (equal? (intersection ll1 ll2) (void))))

(define (distSq p1 p2)
  (+ (expt (- (point-x p1) (point-x p2)) 2)
     (expt (- (point-y p1) (point-y p2)) 2)))
(define (dist p1 p2) (sqrt (distSq p1 p2)))