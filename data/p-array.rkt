#lang racket

(provide (rename-out [get p-array-ref]
                     [set p-array-set]
                     [create make-p-array]
                     [extend p-array-resize]))

;; Jason Hemann and Dan Friedman

(define Diff-i/v car)
(define Diff-t cdr)
(define make-Diff cons)

(define-struct extendable-arr (f v))

(define extend
  (lambda (t)
    (let ((t^ (unbox t)))
      (cond
        ((Arr? t^)
         (let ((f (extendable-arr-f t^))
               (v (extendable-arr-v t^)))
           (let ((size (vector-length v)))
             (let ((new-v (vector-append v (build-vector size (f size)))))
               (set-box! t (make-extendable-arr f new-v))
               t))))
        (else
         (extend (Diff-t t^))
         t)))))

(define Arr?
  (lambda (x) (extendable-arr? x)))

(define create
  (lambda (size f)
    (box (make-extendable-arr f (build-vector size (f 0))))))

(define reroot
  (lambda (t)
    (let ((t^ (unbox t)))
      (cond
        ((Arr? t^) (void))
        (else
         (let ((i/v (Diff-i/v t^))
               (t0 (Diff-t t^)))
           (reroot t0)
           (let ((t0^ (unbox t0)))
             (let ((i (car i/v))
                   (v (cdr i/v)))
               (let ((t0^-v (extendable-arr-v t0^)))
                 (let ((v^ (vector-ref t0^-v i)))
                   (vector-set! t0^-v i v)
                   (set-box! t t0^)
                   (set-box! t0 (make-Diff `(,i . ,v^) t))))))))))))

(define get
  (lambda (t i)
    (let ((t^ (unbox t)))
      (cond
        ((Arr? t^) (vector-ref (extendable-arr-v t^) i))
        (else
         (begin
           (reroot t)
           (let ((t^ (unbox t)))
             (vector-ref (extendable-arr-v t^) i))))))))

(define set
  (lambda (t i v)
    (cond
      ((= i v) t)
      (else
       (reroot t)
       (let ((t^ (unbox t)))
         (let ((t-v (extendable-arr-v t^)))
           (let ((old (vector-ref t-v i)))
             (vector-set! t-v i v)
             (let ((res (box t^)))
               (set-box! t (make-Diff `(,i . ,old) res))
               res))))))))
