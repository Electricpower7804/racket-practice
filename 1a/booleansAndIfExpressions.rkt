;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname booleansIfExpressions) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/image)

;(= 1 2)
;(= 1 1)
;(> 3 9

;(string=? "foo" "bar")

(define I1 (rectangle 10 20 "solid" "red"))
(define I2 (rectangle 20 10 "solid" "blue"))

(if (> (image-width I1)
       (image-width I2))
    "True!"
    "False!")

(and (> (image-height I1) (image-height I2)) ;requires all conditions to be true to return true
     (> (image-width I1) (image-width I2)))

(or (> (image-height I1) (image-height I2)) ;requires only one condition to be true to return true
    (> (image-width I1) (image-width I2)))

(not #true)
(not #false)
