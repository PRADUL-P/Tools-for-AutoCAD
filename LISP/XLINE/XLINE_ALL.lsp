;; XLINE_ALL.LSP – Unified XLINE utilities
;;
;; This script consolidates all XLINE shortcut commands and the custom
;; multi‑spaced XLINE commands (XVN and XHN) into a single file.
;;
;; Provided commands:
;;   XH  – Horizontal XLINE (shortcut)
;;   XV  – Vertical XLINE (shortcut)
;;   XA  – Angled XLINE (shortcut)
;;   XB  – Bisecting XLINE (shortcut)
;;   XO  – Offset XLINE (shortcut)
;;   XVN – Create multiple vertical or horizontal XLINEs with custom count
;;          and spacing (user‑specified direction based on mouse movement).
;;   XHN – Create multiple horizontal XLINEs with custom count and spacing.
;;
;; Load this file with APPLOAD or (load "path/to/XLINE_ALL.lsp") and use the
;; commands directly in the AutoCAD command line.
;; ---------------------------------------------------------------------------
;; Shortcut commands (original functionality)
;; ---------------------------------------------------------------------------

(defun c:XH ()
  (prompt "\n[+XH] Drawing a horizontal XLINE…")
  (command "._xline" "_h")
  (princ))

(defun c:XV ()
  (prompt "\n[+XV] Drawing a vertical XLINE…")
  (command "._xline" "_v")
  (princ))

(defun c:XA ()
  (prompt "\n[+XA] Drawing an angled XLINE…")
  (command "._xline" "_ang")
  (princ))

(defun c:XB ()
  (prompt "\n[+XB] Drawing a bisecting XLINE…")
  (command "._xline" "_bisect")
  (princ))

(defun c:XO ()
  (prompt "\n[+XO] Drawing an offset XLINE…")
  (command "._xline" "_offset")
  (princ))

;; ---------------------------------------------------------------------------
;; XVN – Multiple spaced XLINEs (vertical or horizontal)
;; ---------------------------------------------------------------------------

(defun c:XVN ( / p1 n spacing)
  ;; Prompt for start point
  (setq p1 (getpoint "Pick start point for vertical XLINE: "))
  ;; Number of lines (including the first)
  (setq n (getint "Number of vertical XLINEs (including first): "))
  (while (or (null n) (<= n 0))
    (setq n (getint "Please enter a positive integer for number of XLINEs: ")))
  ;; Spacing between lines
  (setq spacing (getreal "Spacing between vertical XLINEs (drawing units): "))
  (while (null spacing)
    (setq spacing (getreal "Please enter a numeric spacing value: ")))
  ;; Create vertical XLINEs
  (repeat n
    (command "_XLINE" p1 (list 0 1 0))
    (setq p1 (list (+ (car p1) spacing) (cadr p1) (caddr p1)))
  )
  (princ "\nXVN: Vertical XLINE creation complete.")
  (princ))

;; ---------------------------------------------------------------------------
;; XHN – Multiple spaced horizontal XLINEs
;; ---------------------------------------------------------------------------

(defun c:XHN ( / p1 n spacing)
  (setq p1 (getpoint "Pick start point for horizontal XLINE: "))
  (setq n (getint "Number of horizontal XLINEs (including first): "))
  (while (or (null n) (<= n 0))
    (setq n (getint "Please enter a positive integer for number of XLINEs: ")))
  (setq spacing (getreal "Spacing between XLINEs (Y direction, drawing units): "))
  (while (null spacing)
    (setq spacing (getreal "Please enter a numeric spacing value: ")))
  (repeat n
    (command "_XLINE" p1 (list 1 0 0))
    (setq p1 (list (car p1) (+ (cadr p1) spacing) (caddr p1)))
  )
  (princ "\nXHN: Horizontal XLINE creation complete.")
  (princ))

;; End of combined script
(princ "\nXLINE_ALL loaded. Available commands: XH, XV, XA, XB, XO, XVN, XHN.\n")
(princ)
