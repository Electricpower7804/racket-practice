;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname imageFunctions) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/image)

;;(circle radius mode color)

(circle 10 "solid" "red")
(circle 20 "outline" "brown")

;;(rectangle width height mode color)

(rectangle 30 60 "outline" "blue")
(rectangle 60 30 "solid" "black")

;;(text string font-size color)

(text "hello" 24 "orange")
(text "world" 20 "purple")

;;(beside image1 image2 ...)

(beside (circle 10 "solid" "red")
        (circle 20 "solid" "yellow")
        (circle 30 "solid" "green"))

;;(above image1 image2 ...)

(above (circle 10 "solid" "red")
        (circle 20 "solid" "yellow")
        (circle 30 "solid" "green"))

;;(overlay image1 image2 ...)

(overlay (circle 10 "solid" "red")
       (circle 20 "solid" "yellow")
       (circle 30 "solid" "green"))