;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders

;; ===============================================================================
;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define TANK-Y (- HEIGHT TANK-HEIGHT/2))

(define MISSILE (ellipse 5 15 "solid" "red"))

(define MTS (empty-scene WIDTH HEIGHT))

;; ===============================================================================
;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


;; ListOfInvader is one of:
;;  - empty
;;  - (cons Invader ListOfInvader)
;; interp. a list of invaders
(define LOI1 empty)
(define LOI2 (cons I1 (cons I2 empty)))
#;
(define (fn-for-loi loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi))
              (fn-for-loi (rest loi)))]))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))


;; ListOfMissile is one of:
;;  - empty
;;  - (cons Missile ListOfMissile)
;; interp. a list of missiles
(define LOM1 empty)
(define LOM2 (cons M1 (cons M2 empty)))
#;
(define (fn-for-lom lom)
  (cond [(empty? lom) (...)]
        [else
         (... (fn-for-missile (first lom))
              (fn-for-lom (rest lom)))]))


(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; ===============================================================================
;; Functions:

;; Game -> Game
;; start the world with (main G0)
;; 
(define (main g)
  (big-bang g                ; Game
    (on-tick   update-game)  ; Game -> Game
    (to-draw   render-game)  ; Game -> Image
    (stop-when game-over?)   ; Game -> Boolean
    (on-key    handle-key))) ; Game KeyEvent -> Game

;; Game -> Game
;; produce the next ...
(check-random (update-game G0) (make-game (spawn-invader empty) empty (make-tank (+ (/ WIDTH 2) TANK-SPEED) 1)))
(check-random (update-game G1) (make-game (spawn-invader empty) empty (make-tank (+ 50 TANK-SPEED) 1)))
(check-random (update-game (make-game (list (make-invader 10 20 1)) (list (make-missile 10 30)) T1)) (make-game (spawn-invader empty) empty (make-tank (+ 50 TANK-SPEED) 1)))

;(define (update-game g) g) ;stub

(define (update-game s)
  (invader-missle-contact (make-game (spawn-invader (fix-invader-pos (update-invader-pos (game-invaders s))))
                                     (filter-missile (update-missile-pos (game-missiles s)))
                                     (fix-tank-pos (update-tank-pos (game-tank s))))))

;; Game -> Game
;; filter out any missles and invaders that make contact
(check-expect (invader-missle-contact (make-game (list (make-invader 10 20 1.5)) (list (make-missile 10 20)) T1))
              (make-game empty empty T1))
(check-expect (invader-missle-contact (make-game (list (make-invader 10 20 1.5)) empty T1))
              (make-game (list (make-invader 10 20 1.5)) empty T1))
(check-expect (invader-missle-contact (make-game empty (list (make-missile 10 20)) T1))
              (make-game empty (list (make-missile 10 20)) T1))

;(define (invader-missle-contact g) g) ;stub

(define (invader-missle-contact s)
  (make-game (contact-loi (game-invaders s) (game-missiles s))
             (contact-lom (game-invaders s) (game-missiles s))
             (game-tank s)))


;; ListOfInvader ListOfMissile -> ListOfInvader
;; produce filtered list of invaders. Remove an invader if its hitbox makes contact within a missile
(check-expect (contact-loi (list (make-invader 20 90 1)) (list (make-missile 90 30)))
              (list (make-invader 20 90 1)))
(check-expect (contact-loi (list (make-invader 80 29 1) (make-invader 30 30 1)) (list (make-missile 30 40)))
              (list (make-invader 80 29 1)))

;(define (contact-loi loi lom) loi) ;stub

(define (contact-loi loi lom)
  (cond [(or (empty? loi)
             (empty? lom)) loi]
        [else
         (if (touch-m? (first loi) lom)
             (contact-loi (rest loi) lom)
             (cons (first loi)
                   (contact-loi (rest loi) lom)))]))


;; Invader ListOfMissile -> Boolean
;; produce true if invader's hitbox makes contact with any missile in ListOfMissile
(check-expect (touch-m? (make-invader 10 20 -1) (list (make-missile 90 30) (make-missile 100 100))) false)
(check-expect (touch-m? (make-invader 90 30 1) (list (make-missile 90 30) (make-missile 100 100))) true)
(check-expect (touch-m? (make-invader 110 110 1) (list (make-missile 90 30) (make-missile 100 100))) true)

;(define (touch-m? i lom) false) ;stub

(define (touch-m? i lom)
  (cond [(empty? lom) false]
        [(and
          (and (>=  HIT-RANGE    (- (invader-x i) (missile-x (first lom))))
               (<= (- HIT-RANGE) (- (invader-x i) (missile-x (first lom)))))
          (and (>=  HIT-RANGE    (- (invader-y i) (missile-y (first lom))))
               (<= (- HIT-RANGE) (- (invader-y i) (missile-y (first lom)))))) true]
        [else (touch-m? i (rest lom))]))


;; ListOfInvader ListOfMissile -> ListOfMissile
;; produce filtered list of missiles. Remove a missile if it makes contact within an invader's hitbox
(check-expect (contact-lom (list (make-invader 20 90 1)) (list (make-missile 90 30)))
              (list (make-missile 90 30)))
(check-expect (contact-lom (list (make-invader 80 29 1) (make-invader 30 30 1)) (list (make-missile 30 40)))
              empty)

;(define (contact-lom loi lom) lom) ;stub

(define (contact-lom loi lom)
  (cond [(or (empty? loi)
             (empty? lom)) lom]
        [else
         (if (touch-i? loi (first lom))
             (contact-lom loi (rest lom))
             (cons (first lom)
                   (contact-lom loi (rest lom))))]))


;; ListOfInvader Missile -> Boolean
;; produce true if a missile makes contact with any invader's hitbox in ListOfInvader
(check-expect (touch-i? (list (make-invader 90 30 1) (make-invader 100 100 -1)) (make-missile 10 20)) false)
(check-expect (touch-i? (list (make-invader 90 30 1) (make-invader 100 100 1)) (make-missile 90 30)) true)
(check-expect (touch-i? (list (make-invader 90 30 1) (make-invader 100 100 -1)) (make-missile 110 110)) true)

;(define (touch-i? loi m) false) ;stub

(define (touch-i? loi m)
  (cond [(empty? loi) false]
        [(and
          (and (>=  HIT-RANGE    (- (missile-x m) (invader-x (first loi))))
               (<= (- HIT-RANGE) (- (missile-x m) (invader-x (first loi)))))
          (and (>=  HIT-RANGE    (- (missile-y m) (invader-y (first loi))))
               (<= (- HIT-RANGE) (- (missile-y m) (invader-y (first loi)))))) true]
        [else (touch-i? (rest loi) m)]))


;; ListOfInvader -> ListOfInvader
;; depending on random chance, spawn new invaders at top of map
(check-random (spawn-invader empty) (if (< (random 5000) INVADE-RATE)
                                        (cons (make-invader (random WIDTH) -30 1) empty)
                                        empty))
(check-random (spawn-invader (cons I1 empty)) (if (< (random 5000) INVADE-RATE)
                                                  (cons (make-invader (random WIDTH) -30 1) (cons I1 empty))
                                                  (cons I1 empty)))

;(define (spawn-invader loi) loi) ;stub

(define (spawn-invader loi)
  (if (< (random 5000) INVADE-RATE)
      (cons (make-invader (random WIDTH) -30 1) loi)
      loi))


;; ListOfInvader -> ListOfInvader
;; move invaders inside of map and swap x direction if invader position exceeds WIDTH or HEIGHT
(check-expect (fix-invader-pos empty) empty)
(check-expect (fix-invader-pos (cons I1 empty)) (cons I1 empty))
(check-expect (fix-invader-pos (cons I1 (cons I2 empty))) (cons I1 (cons I2 empty)))
(check-expect (fix-invader-pos (cons I1
                                     (cons (make-invader (+ WIDTH 10) 90 1) empty)))
              (cons I1 (cons (make-invader WIDTH 90 -1) empty)))
(check-expect (fix-invader-pos (cons I1
                                     (cons (make-invader -10 90 -1) empty)))
              (cons I1 (cons (make-invader 0 90 1) empty)))

;(define (fix-invader-pos loi) loi) ;stub

(define (fix-invader-pos loi)
  (cond [(empty? loi) empty]
        [else
         (cond [(> (invader-x (first loi)) WIDTH)
                (cons (make-invader WIDTH
                                    (invader-y (first loi))
                                    (- (invader-dx (first loi))))
                      (fix-invader-pos (rest loi)))]
               [(< (invader-x (first loi)) 0)
                (cons (make-invader 0
                                    (invader-y (first loi))
                                    (- (invader-dx (first loi))))
                      (fix-invader-pos (rest loi)))]
               [else (cons (first loi)
                           (fix-invader-pos (rest loi)))])]))
             


;; ListOfInvader -> ListOfInvader
;; move invader dx pixels along the x axis and move invader the same number of pixels on the y axis
(check-expect (update-invader-pos empty) empty)
(check-expect (update-invader-pos (cons I1 empty))
              (cons (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) empty))
(check-expect (update-invader-pos (cons I1 (cons I2 empty)))
              (cons (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12)
                    (cons (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) empty)))

;(define (update-invader-pos loi) loi) ;stub

(define (update-invader-pos loi)
  (cond [(empty? loi) empty]
        [else
         (cons (move-invader (first loi))
               (update-invader-pos (rest loi)))]))


;; Invader -> Invader
;; move invader INVADER-Y-SPEED pixels down MTS and INVADER-X-SPEED pixels along MTS (x direction depends on dx value of Invader)
(check-expect (move-invader I1)
              (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12))
(check-expect (move-invader I2)
              (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10))

;(define (move-invader i) i) ;stub

(define (move-invader i)
  (cond [(> (invader-dx i) 0)
         (make-invader (+ (invader-x i) INVADER-X-SPEED)
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (invader-dx i))]
        [(< (invader-dx i) 0)
         (make-invader (- (invader-x i) INVADER-X-SPEED)
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (invader-dx i))]))

;; ListOfMissile -> ListOfMissile
;; remove any missiles that are outside of the map (if y pos < 0)
(check-expect (filter-missile empty) empty)
(check-expect (filter-missile (cons M1 empty)) (cons M1 empty))
(check-expect (filter-missile (cons M1 (cons (make-missile 10 -80) empty))) (cons M1 empty))

;(define (filter-missile lom) lom) ;stub

(define (filter-missile lom)
  (cond [(empty? lom) empty]
        [else
         (if (< (missile-y (first lom)) 0)
             (filter-missile (rest lom))
             (cons (first lom)
                   (filter-missile (rest lom))))]))


;; ListOfMissile -> ListOfMissile
;; move missile up the screen by MISSILE-SPEED pixels
(check-expect (update-missile-pos empty) empty)
(check-expect (update-missile-pos (cons M1 empty))
              (cons (make-missile 150 (- 300 MISSILE-SPEED)) empty))
(check-expect (update-missile-pos (cons M1 (cons M2 empty)))
              (cons (make-missile 150 (- 300 MISSILE-SPEED))
                    (cons (make-missile (invader-x I1) (- (+ (invader-y I1) 10) MISSILE-SPEED)) empty)))

;(define (update-missile-pos lom) lom) ;stub

(define (update-missile-pos lom)
  (cond [(empty? lom) empty]
        [else
         (cons (move-missile (first lom))
               (update-missile-pos (rest lom)))]))


;; Missile -> Missile
;; move an individual missile up MTS by MISSILE-SPEED pixels
(check-expect (move-missile (make-missile 10 30)) (make-missile 10 (- 30 MISSILE-SPEED)))
(check-expect (move-missile (make-missile 70 90)) (make-missile 70 (- 90 MISSILE-SPEED)))

;(define (move-missile m) m) ;stub

(define (move-missile m)
  (make-missile (missile-x m)
                (- (missile-y m) MISSILE-SPEED)))


;; Tank -> Tank
;; move tank back into MTS if its position exceeds WIDTH or HEIGHT
(check-expect (fix-tank-pos T0) T0)
(check-expect (fix-tank-pos T1) T1)
(check-expect (fix-tank-pos (make-tank -10 -1)) (make-tank 0 -1))
(check-expect (fix-tank-pos (make-tank (* 2 WIDTH) 1)) (make-tank WIDTH 1))

;(define (fix-tank-pos t) t) ;stub

(define (fix-tank-pos t)
  (cond [(> (tank-x t) WIDTH) (make-tank WIDTH (tank-dir t))]
        [(< (tank-x t) 0) (make-tank 0 (tank-dir t))]
        [else t]))

;; Tank -> Tank
;; move tank by TANK-SPEED pixels across x axis
(check-expect (update-tank-pos T0) (make-tank (+ (/ WIDTH 2) TANK-SPEED) 1))
(check-expect (update-tank-pos T1) (make-tank (+ 50 TANK-SPEED) 1))
(check-expect (update-tank-pos T2) (make-tank (- 50 TANK-SPEED) -1))

;(define (update-tank-pos t) t) ;stub

(define (update-tank-pos t)
  (cond [(> (tank-dir t) 0)
         (make-tank (+ (tank-x t) TANK-SPEED)
                    (tank-dir t))]
        [(< (tank-dir t) 0)
         (make-tank (- (tank-x t) TANK-SPEED)
                    (tank-dir t))]))


;; Game -> Image
;; render ... 
(check-expect (render-game (make-game empty empty T1))
              (place-image TANK 50 TANK-Y MTS))
(check-expect (render-game (make-game (list (make-invader 20 30 1)) (list (make-missile 80 80) (make-missile 70 70)) T1))
              (place-image TANK 50 TANK-Y (place-image MISSILE 80 80 (place-image MISSILE 70 70 (place-image INVADER 20 30 MTS)))))

;(define (render-game g) MTS) ;stub

(define (render-game s)
  (render-tank (game-tank s)
               (render-missiles (game-missiles s)
                                (render-invaders (game-invaders s)))))


;; Tank Image -> Image
;; produce image of tank on given scene
(check-expect (render-tank T1 MTS) (place-image TANK 50 TANK-Y MTS))
(check-expect (render-tank T1 (render-missiles (list (make-missile 100 200) (make-missile 90 90)) MTS))
              (place-image TANK 50 TANK-Y (place-image MISSILE 100 200 (place-image MISSILE 90 90 MTS))))

;(define (render-tank t i) i) ;stub

(define (render-tank t i)
  (place-image TANK
               (tank-x t)
               TANK-Y
               i))

;; ListOfMissile Image -> Image
;; produce images of missiles on given scene
(check-expect (render-missiles empty MTS) MTS)
(check-expect (render-missiles (list (make-missile 100 200) (make-missile 90 90)) MTS)
              (place-image MISSILE 100 200 (place-image MISSILE 90 90 MTS)))

;(define (render-missiles lom i) i) ;stub

(define (render-missiles lom i)
  (cond [(empty? lom) i]
        [else
         (place-image MISSILE
                      (missile-x (first lom))
                      (missile-y (first lom))
                      (render-missiles (rest lom) i))]))


;; ListOfInvader -> Image
;; produce images of invaders on MTS
(check-expect (render-invaders empty) MTS)
(check-expect (render-invaders (list (make-invader 10 30 1) (make-invader 100 200 -1)))
              (place-image INVADER 10 30 (place-image INVADER 100 200 MTS)))

;(define (render-invaders loi) MTS) ;stub

(define (render-invaders loi)
  (cond [(empty? loi) MTS]
        [else
         (place-image INVADER
                      (invader-x (first loi))
                      (invader-y (first loi))
                      (render-invaders (rest loi)))]))


;; Game -> Boolean
;; produce true if invader reaches bottom of screen (HEIGHT)
(check-expect (game-over? (make-game empty empty T1)) false)
(check-expect (game-over? (make-game (list (make-invader 20 30 1) (make-invader 1 HEIGHT 1)) empty T1)) true)
(check-expect (game-over? (make-game (list (make-invader 80 90 1) (make-invader 80 80 1)) empty T1)) false)

;(define (game-over? g) false) ;stub

(define (game-over? s)
  (touches-ground? (game-invaders s)))


;; ListOfInvader -> Boolean
;; produce true if one of the invaders touches the bottom of the map
(check-expect (touches-ground? (list I1)) false)
(check-expect (touches-ground? (list I1 I2)) true)
(check-expect (touches-ground? (list I1 I1 I1)) false)

;(define (touches-ground? loi) false) ;stub

(define (touches-ground? loi)
  (cond [(empty? loi) false]
        [else
         (if (>= (invader-y (first loi)) HEIGHT)
             true
             (touches-ground? (rest loi)))]))


;; Game KeyEvent -> Game
;; move tank left or right, depending on key pressed; shoot laser if space bar pressed
(check-expect (handle-key G2 "left") (make-game (list (make-invader 150 100 12)) (list (make-missile 150 300)) (make-tank 50 -1)))
(check-expect (handle-key G1 "right") G1)
(check-expect (handle-key G2 "right") G2)
(check-expect (handle-key G1 "a") G1)

(define (handle-key g ke)
  (cond [(key=? ke "left")
         (make-game
          (game-invaders g)
          (game-missiles g)
          (move-tank-left (game-tank g)))]
        [(key=? ke "right")
         (make-game
          (game-invaders g)
          (game-missiles g)
          (move-tank-right (game-tank g)))]
        [(key=? ke " ")
         (make-game
          (game-invaders g)
          (shoot-missile (game-missiles g) (tank-x (game-tank g)))
          (game-tank g))]
        [else g]))


;; Tank -> Tank
;; switch direction of tank to left
(check-expect (move-tank-left T1) (make-tank 50 (- 1)))
(check-expect (move-tank-left T2) (make-tank 50 -1))

;(define (move-tank-left t) t) ;stub

(define (move-tank-left t)
  (cond [(> (tank-dir t) 0)
         (make-tank (tank-x t)
             (- (tank-dir t)))]
        [else t]))


;; Tank -> Tank
;; switch direction of tank to right
(check-expect (move-tank-right T1) (make-tank 50 1))
(check-expect (move-tank-right T2) (make-tank 50 (- -1)))

;(define (move-tank-right t) t) ;stub

(define (move-tank-right t)
  (cond  [(< (tank-dir t) 0)
         (make-tank (tank-x t)
             (- (tank-dir t)))]
        [else t]))


;; ListOfMissile -> ListOfMissile
;; add a missile positioned at the tip of tank barrel to ListOfMissile when space bar is pressed
(check-expect (shoot-missile empty 10) (list (make-missile 10 TANK-Y)))
(check-expect (shoot-missile (list (make-missile 20 20)) 30) (list (make-missile 30 TANK-Y) (make-missile 20 20)))

;(define (shoot-missile lom x) lom) ;stub

(define (shoot-missile lom x)
  (cons (make-missile x TANK-Y)
        lom))