;;; ===============================================================
;;; AutoCAD Selection Tools – LISP Utilities
;;; Description: Handy object selection tools for fast workflow.
;;; ---------------------------------------------------------------
;;; 📌 COMMANDS OVERVIEW:
;;; SA   – Select all objects of same type (e.g., LINE, CIRCLE)
;;; SAT  – Select all objects of same type and same layer
;;; SAL  – Select all objects on same layer
;;; SAC  – Select all objects of same color
;;; SAA  – Select all objects in drawing
;;; SAB  – Select all instances of same block reference
;;; SLT  – Select all objects with same linetype
;;; ===============================================================

;;; --- Command: SA
;;; Select all objects of the same type (e.g., LINE, CIRCLE)
(defun c:SA ( / ss1 sel objType ss )
  (setq ss1 (ssget "_I"))
  (setq sel (if ss1 (ssname ss1 0) (car (entsel "\nSelect an object (SA): "))))
  (if sel
    (progn
      (setq objType (cdr (assoc 0 (entget sel))))
      (setq ss (ssget "_X" (list (cons 0 objType))))
      (if ss
        (progn
          (sssetfirst nil ss)
          (princ (strcat "\n✅ Selected " (itoa (sslength ss)) " object(s) of type: " objType))
        )
        (princ "\n⚠️ No objects of same type found.")
      )
    )
    (princ "\n⚠️ No object selected.")
  )
  (princ)
)

;;; --- Command: SAT
;;; Select all objects of same type AND same layer
(defun c:SAT ( / ss1 sel ent objType lay ss )
  (setq ss1 (ssget "_I"))
  (setq sel (if ss1 (ssname ss1 0) (car (entsel "\nSelect object (SAT): "))))
  (if sel
    (progn
      (setq ent (entget sel))
      (setq objType (cdr (assoc 0 ent)))
      (setq lay (cdr (assoc 8 ent)))
      (setq ss (ssget "_X" (list (cons 0 objType) (cons 8 lay))))
      (if ss
        (progn
          (sssetfirst nil ss)
          (princ (strcat "\n✅ Selected " (itoa (sslength ss)) " of type " objType " on layer '" lay "'"))
        )
        (princ "\n⚠️ No similar objects found on the same layer.")
      )
    )
    (princ "\n⚠️ No object selected.")
  )
  (princ)
)

;;; --- Command: SAL
;;; Select all objects on the same layer
(defun c:SAL ( / ss1 sel lay ss )
  (setq ss1 (ssget "_I"))
  (setq sel (if ss1 (ssname ss1 0) (car (entsel "\nSelect object (SAL): "))))
  (if sel
    (progn
      (setq lay (cdr (assoc 8 (entget sel))))
      (setq ss (ssget "_X" (list (cons 8 lay))))
      (if ss
        (progn
          (sssetfirst nil ss)
          (princ (strcat "\n✅ Selected " (itoa (sslength ss)) " object(s) on layer '" lay "'"))
        )
        (princ "\n⚠️ No objects found on same layer.")
      )
    )
    (princ "\n⚠️ No object selected.")
  )
  (princ)
)

;;; --- Command: SAC
;;; Select all objects of same color
(defun c:SAC ( / ss1 sel col ss )
  (setq ss1 (ssget "_I"))
  (setq sel (if ss1 (ssname ss1 0) (car (entsel "\nSelect object (SAC): "))))
  (if sel
    (progn
      (setq col (cdr (assoc 62 (entget sel))))
      (if col
        (progn
          (setq ss (ssget "_X" (list (cons 62 col))))
          (if ss
            (progn
              (sssetfirst nil ss)
              (princ (strcat "\n✅ Selected " (itoa (sslength ss)) " object(s) with color " (itoa col)))
            )
            (princ "\n⚠️ No objects found with that color.")
          )
        )
        (princ "\n⚠️ Object has no assigned color.")
      )
    )
    (princ "\n⚠️ No object selected.")
  )
  (princ)
)

;;; --- Command: SAA
;;; Select ALL objects in drawing
(defun c:SAA ( / ss )
  (setq ss (ssget "_X"))
  (if ss
    (progn
      (sssetfirst nil ss)
      (princ (strcat "\n✅ Selected ALL (" (itoa (sslength ss)) ") objects in drawing."))
    )
    (princ "\n⚠️ No objects found.")
  )
  (princ)
)

;;; --- Command: SAB
;;; Select all block references of the same name
(defun c:SAB ( / ss1 sel ent bname ss )
  (setq ss1 (ssget "_I"))
  (setq sel (if ss1 (ssname ss1 0) (car (entsel "\nSelect block reference (SAB): "))))
  (if sel
    (progn
      (setq ent (entget sel))
      (if (= (cdr (assoc 0 ent)) "INSERT")
        (progn
          (setq bname (cdr (assoc 2 ent)))
          (setq ss (ssget "_X" (list (cons 0 "INSERT") (cons 2 bname))))
          (if ss
            (progn
              (sssetfirst nil ss)
              (princ (strcat "\n✅ Selected " (itoa (sslength ss)) " instance(s) of block: " bname))
            )
            (princ "\n⚠️ No other instances of block found.")
          )
        )
        (princ "\n⚠️ Not a block reference.")
      )
    )
    (princ "\n⚠️ No object selected.")
  )
  (princ)
)

;;; --- Command: SLT
;;; Select all objects of same linetype
(defun c:SLT ( / ss1 sel ltype ss )
  (setq ss1 (ssget "_I"))
  (setq sel (if ss1 (ssname ss1 0) (car (entsel "\nSelect object (SLT): "))))
  (if sel
    (progn
      (setq ltype (cdr (assoc 6 (entget sel))))
      (if ltype
        (progn
          (setq ss (ssget "_X" (list (cons 6 ltype))))
          (if ss
            (progn
              (sssetfirst nil ss)
              (princ (strcat "\n✅ Selected " (itoa (sslength ss)) " object(s) with linetype: " ltype))
            )
            (princ "\n⚠️ No objects found with that linetype.")
          )
        )
        (princ "\n⚠️ Object has no linetype.")
      )
    )
    (princ "\n⚠️ No object selected.")
  )
  (princ)
)
