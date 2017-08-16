#lang scribble/manual

@(require (for-label data/p-array
                     racket/base
                     racket/contract/base)
          scribble/example)

@(define (make-parr-eval)
   (make-base-eval #:lang 'racket/base
                   '(require data/p-array)))

@(define-syntax-rule (parr-examples body ...)
   (examples #:eval (make-parr-eval) body ...))

@title{Semi-Persistent Arrays}
@author["Jason Hemann"
        "Dan Friedman"
        @author+email["Sam Tobin-Hochstadt"
                      "samth@ccs.neu.edu"]]
@defmodule[data/p-array]

This library provides an implementation of
@deftech[#:key "semi-persistent array"]{semi-persistent arrays}. Semi-persistent
arrays present functional get and set operations that return new arrays
efficiently, but existing arrays may be modified under the covers during
construction of new arrays. Thus the data structure is persistent, but neither
thread safe nor implemented in a purely functional manner. See
@hyperlink["https://www.lri.fr/~filliatr/ftp/publis/puf-wml07.pdf"]{A Persistent
 Union-Find Data Structure} by Sylvain Conchon and Jean-Christophe Filliâtre for
more details.

@defproc[(p-array? [v any/c]) boolean?]{
 Returns @racket[#t] if @racket[v] is a @tech{semi-persistent array}, returns
 @racket[#f] otherwise.}

@defproc[(make-p-array [size fixnum?]
                       [build-item (-> exact-nonnegative-integer? any/c)])
         p-array?]{
 Returns a @tech{semi-persistent array} containing @racket[size] items, where
 each item is the result of applying @racket[build-item] to its position in the
 array (similarly to @racket[build-list] and @racket[build-vector]).

 @(parr-examples
   (make-p-array 5 (λ (i) (* i 10))))}

@defproc[(p-array-ref [parr p-array?] [i fixnum?]) any/c]{
 Returns the element of @racket[parr] at position @racket[i] in amortized
 constant space and time.

 @(parr-examples
   (eval:check (p-array-ref (make-p-array 5 values) 2) 2))}

@defproc[(p-array-set [parr p-array?] [i fixnum?] [v any/c]) p-array?]{
 Returns a new @tech{semi-persistent array} that is equivalent to @racket[parr]
 with @racket[v] at position @racket[i]. The new array is constructed in
 amortized constant space and time.

 @(parr-examples
   (define changed-arr
     (p-array-set (make-p-array 5 values) 4 'foo))
   (eval:check (p-array-ref changed-arr 4) 'foo))}

@defproc[(p-array-resize [parr p-array?]) p-array?]{
 Returns a new @tech{semi-persistent array} that is equivalent to @racket[parr]
 with its size doubled. New positions in the array are filled using the initial
 @racket[build-item] procedure provided during the construction of @racket[parr]
 with @racket[make-p-array].

 @(parr-examples
   (define resized (p-array-resize (make-p-array 5 values)))
   resized
   (eval:check (p-array-ref resized 7) 7))}
