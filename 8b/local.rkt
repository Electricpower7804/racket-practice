;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname local) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

;; To form a local expression:

;(local [<definition> ...] <---- definitions
;  <expression>)           <---- body

(local [(define a 1)  ;definitions
        (define b 2)]

  (+ a b))            ;body

(local [(define p "accio ")
        (define (fetch n) (string-append p n))]

  (fetch "portkey"))