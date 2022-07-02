;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname structures) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

;; Compound data: information where two or more values naturally belong together
;; Examples:
;;  - The (x, y) position of an object
;;  - The first and last name of a person
;;  - The name, supervisor, and salary of an employee

(define-struct pos (x y))

(define P1 (make-pos 3 6))  ;constructor
(define P2 (make-pos 2 8))

(pos-x P1)                  ;selectors
(pos-y P2)

(pos? P1)       ;true       ;predicate 
(pos? "hello")  ;false

;; To form a structure definition:

;; (define-struct <name> (<name>...))
;;                  |        |
;;            structure name |
;;                           |
;;                      field name(s)


;; A structure definition defines:
;; constructor: make-<structure-name>
;; selector(s): <structure-name>-<field-name>
;; predicate: <structure-name>?


;; (define-struct pos (x y)) defines:
;; constructor: make-pos
;; selectors: pos-x pos-y
;; predicate: pos?