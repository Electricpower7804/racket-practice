#lang racket

(define (incrementAll myList)
  (if (null? myList)
      '()
      (cons (+ 1 (first myList)) (incrementAll (rest myList)))))

(incrementAll '(1 2 3 4 5 6 7 8 9 10))