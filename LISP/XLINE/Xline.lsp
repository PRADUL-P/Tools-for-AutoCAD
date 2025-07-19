;; XLINE.LSP - Extended XLINE Shortcuts for AutoCAD
;; Description: Provides shortcut commands to draw XLINEs quickly using AutoLISP wrappers.
;; Commands Included:
;; - XH : Horizontal XLINE
;; - XV : Vertical XLINE
;; - XA : Angled XLINE
;; - XB : Bisecting XLINE
;; - XO : Offset XLINE

(defun c:XH ()
  ;; Command: XH
  ;; Purpose: Draw a horizontal XLINE (equivalent to XL > Hor)
  (prompt "\n[+XH] Drawing a horizontal XLINE...")
  (command "._xline" "_h")
  (princ)
)

(defun c:XV ()
  ;; Command: XV
  ;; Purpose: Draw a vertical XLINE (equivalent to XL > Ver)
  (prompt "\n[+XV] Drawing a vertical XLINE...")
  (command "._xline" "_v")
  (princ)
)

(defun c:XA ()
  ;; Command: XA
  ;; Purpose: Draw an angled XLINE (equivalent to XL > Ang)
  (prompt "\n[+XA] Drawing an angled XLINE...")
  (command "._xline" "_ang")
  (princ)
)

(defun c:XB ()
  ;; Command: XB
  ;; Purpose: Draw a bisecting XLINE (equivalent to XL > Bisect)
  (prompt "\n[+XB] Drawing a bisecting XLINE...")
  (command "._xline" "_bisect")
  (princ)
)

(defun c:XO ()
  ;; Command: XO
  ;; Purpose: Offset an existing XLINE (equivalent to XL > Offset)
  (prompt "\n[+XO] Drawing an offset XLINE...")
  (command "._xline" "_offset")
  (princ)
)

;; End of File
(princ)
