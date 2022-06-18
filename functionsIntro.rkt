;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname functionsIntro) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/image)

;(define (function-name parameters...) (body))

(define (bulb c)
  (circle 40 "solid" c))

(bulb (string-append "re" "d")) ;the value of the string-append function returns as:

(bulb "red") ;which then calls the following circle function using the argument red:

(circle 40 "solid" "red") ;which then evaluates to a red circle