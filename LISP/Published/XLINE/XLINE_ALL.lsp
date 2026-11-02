;; =============================================================================
;; XLINE_ALL.LSP – Unified Extended XLINE Utilities for AutoCAD
;; =============================================================================
;; Commands Included:
;;   XH  : Quick Horizontal XLINE
;;   XV  : Quick Vertical XLINE
;;   XA  : Angled XLINE
;;   XB  : Bisecting XLINE
;;   XO  : Offset XLINE
;;   XVN : Array multiple VERTICAL XLINEs with custom count, spacing & mouse direction
;;   XHN : Array multiple HORIZONTAL XLINEs with custom count, spacing & mouse direction
;; =============================================================================

;; -----------------------------------------------------------------------------
;; Basic Shortcuts
;; -----------------------------------------------------------------------------

(defun c:XH ()
  (prompt "\n[+XH] Drawing a horizontal XLINE...")
  (command "._xline" "_h")
  (princ)
)

(defun c:XV ()
  (prompt "\n[+XV] Drawing a vertical XLINE...")
  (command "._xline" "_v")
  (princ)
)

(defun c:XA ()
  (prompt "\n[+XA] Drawing an angled XLINE...")
  (command "._xline" "_ang")
  (princ)
)

(defun c:XB ()
  (prompt "\n[+XB] Drawing a bisecting XLINE...")
  (command "._xline" "_bisect")
  (princ)
)

(defun c:XO ()
  (prompt "\n[+XO] Drawing an offset XLINE...")
  (command "._xline" "_offset")
  (princ)
)

;; -----------------------------------------------------------------------------
;; XVN – Array of Spaced Vertical XLINEs (Mouse-Direction Aware)
;; -----------------------------------------------------------------------------
(defun c:XVN ( / oldEcho p1 p2 n dx curPt )
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "_.undo" "_group")

  ;; 1. Base / Start point
  (setq p1 (getpoint "\nSpecify start point for first vertical XLINE: "))
  (if p1
    (progn
      ;; 2. Count
      (initget 6) ; Non-zero, positive integer
      (setq n (getint "\nEnter number of vertical XLINEs (including first) <2>: "))
      (if (null n) (setq n 2))

      ;; 3. Spacing & Direction (move cursor left/right and click or enter distance)
      (setq p2 (getpoint p1 "\nSpecify spacing & direction (move cursor Left/Right & enter distance or click): "))
      (if p2
        (progn
          (setq dx (- (car p2) (car p1)))
          (if (equal dx 0.0 1e-6)
            (setq dx (getdist p1 "\nLines would overlap. Enter numeric spacing distance: "))
          )
          (if (and dx (/= dx 0.0))
            (progn
              ;; Use native vertical option of _XLINE
              (command "._xline" "_v")
              (setq curPt p1)
              (repeat n
                (command "_none" curPt)
                (setq curPt (list (+ (car curPt) dx) (cadr curPt) (caddr curPt)))
              )
              (command "") ; Close XLINE command properly
              (princ (strcat "\nXVN: Created " (itoa n) " vertical XLINEs (Spacing: " (rtos (abs dx) 2 2)
                             (if (> dx 0) " -> Right" " <- Left") ")."))
            )
          )
        )
      )
    )
  )

  (command "_.undo" "_end")
  (setvar "CMDECHO" oldEcho)
  (princ)
)

;; -----------------------------------------------------------------------------
;; XHN – Array of Spaced Horizontal XLINEs (Mouse-Direction Aware)
;; -----------------------------------------------------------------------------
(defun c:XHN ( / oldEcho p1 p2 n dy curPt )
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "_.undo" "_group")

  ;; 1. Base / Start point
  (setq p1 (getpoint "\nSpecify start point for first horizontal XLINE: "))
  (if p1
    (progn
      ;; 2. Count
      (initget 6) ; Non-zero, positive integer
      (setq n (getint "\nEnter number of horizontal XLINEs (including first) <2>: "))
      (if (null n) (setq n 2))

      ;; 3. Spacing & Direction (move cursor up/down and click or enter distance)
      (setq p2 (getpoint p1 "\nSpecify spacing & direction (move cursor Up/Down & enter distance or click): "))
      (if p2
        (progn
          (setq dy (- (cadr p2) (cadr p1)))
          (if (equal dy 0.0 1e-6)
            (setq dy (getdist p1 "\nLines would overlap. Enter numeric spacing distance: "))
          )
          (if (and dy (/= dy 0.0))
            (progn
              ;; Use native horizontal option of _XLINE
              (command "._xline" "_h")
              (setq curPt p1)
              (repeat n
                (command "_none" curPt)
                (setq curPt (list (car curPt) (+ (cadr curPt) dy) (caddr curPt)))
              )
              (command "") ; Close XLINE command properly
              (princ (strcat "\nXHN: Created " (itoa n) " horizontal XLINEs (Spacing: " (rtos (abs dy) 2 2)
                             (if (> dy 0) " -> Up" " -> Down") ")."))
            )
          )
        )
      )
    )
  )

  (command "_.undo" "_end")
  (setvar "CMDECHO" oldEcho)
  (princ)
)

(princ "\n==================================================================")
(princ "\n XLINE_ALL Loaded!")
(princ "\n Commands: XH, XV, XA, XB, XO")
(princ "\n   XVN : Array vertical XLINEs with count, spacing & mouse direction")
(princ "\n   XHN : Array horizontal XLINEs with count, spacing & mouse direction")
(princ "\n==================================================================\n")
(princ)