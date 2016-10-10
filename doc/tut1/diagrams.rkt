#lang racket

(require metapict)
(require metapict/pict)

(define dots '((-3/3 1/10)
               (-2/3 1/20)
               (-1/3 4/10)
               (0/3 1/30)
               (1/3 1/30)
               (2/3 1/40)
               (3/3 1/20)))

(set! dots (map (lambda(n)
                  (apply pt n)) dots))

(define (generate-curves dots)
  (let loop ((d dots) (d1 (cdr dots)) (curves '()))
    (if (or (null? d) (null? d1))
        curves
        (loop (cdr d)
              (cdr d1)
              (append curves `(,(curve (car d) .. (car d1))))))))

(define (save name-base . args)
  (let loop ((a args) (i 1))
    (save-pict (~a name-base i ".png") (scale 6 (car a)))
    (if (null? (cdr a))
        (void)
        (loop (cdr a) (add1 i)))))

;; TRAIL EXPLANATION

(save "trail" (penwidth 2 (apply draw dots))
              (penwidth 2 (apply draw (generate-curves dots))))

;; NORMALS
(define draw-normal-diag 
  (lambda (ang lab [target origo])
  (penwidth 2
          (draw
           (draw-arrow (curve (rotated ang (pt 0 -0.8)) .. (rotated ang target)))
           (clipped (draw (curve (rotated ang (pt -1 -0.8)) .. (rotated ang (pt 1 -0.8))))
                  (rectangle (pt -1 -0.85) (pt 1 1)))
           (label-bot (~a lab) (pt 0 -0.8))))))

;; normals
(save "normal"
      (draw-normal-diag 0 "(0, 1)")
      (draw-normal-diag (/ pi 2) "(-1, 0)")
      (draw-normal-diag (/ pi 4) "(-0.7, 0.7)-ish"))

(save "walljump"
      (draw
       (rectangle (pt 0.2 0.3) (pt 0.8 -0.3))
       (draw-normal-diag (/ pi 2) "wall (-1, 0)"))
      (draw
       (rectangle (pt 0.2 0.3) (pt 0.8 -0.3))
       (draw-arrow (curve (pt 0.8 0) .. (pt 0 0.7)))
       (color (make-color* "gray") (draw-normal-diag (/ pi 2) ""))))

