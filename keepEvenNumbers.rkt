#lang racket

(define (keepEvenNumbers myList)
  (cond [(null? myList)
         '()]
        [(odd? (first myList))
         (keepEvenNumbers (rest myList))]
        [else
         (cons (first myList) (keepEvenNumbers (rest myList)))]))

(keepEvenNumbers '(1 2 3 4 5 6 7 8 9 10))