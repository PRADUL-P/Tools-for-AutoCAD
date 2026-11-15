;;; =========================================================================
;;; MTEXT2ATTR.lsp – Convert TEXT and MTEXT to Attribute Definitions (ATTDEF)
;;; =========================================================================
;;;
;;; DESCRIPTION:
;;;   Batch-converts single-line TEXT and multi-line MTEXT objects into
;;;   Attribute Definitions (ATTDEF) in-place.
;;;
;;;   FEATURES:
;;;     - Preserves original Letter Casing (no forced uppercase!).
;;;     - Clean Prompt without any "Enter ... :" preloaded text.
;;;     - Preserves exact position, alignment/justification, text height,
;;;       rotation, layer, text style, color, width factor, and oblique angle.
;;;     - Works in Model Space, Paper Space, and inside BLOCK EDITOR (BEDIT).
;;;     - Supports pre-selection (pickfirst) and post-selection.
;;;
;;; COMMANDS:
;;;   MT2ATT  - Main command (MText / Text to Attribute)
;;;   M2A     - Fast keyboard shortcut
;;;   T2A     - Text to Attribute shortcut
;;;   TXT2ATT - Alias
;;;
;;; =========================================================================

(vl-load-com)

;;; -------------------------------------------------------------------------
;;; HELPER: Strip MText formatting codes (\f..., \P, etc.)
;;; -------------------------------------------------------------------------
(defun clean-mtext-string (str / regex)
  (if (and str (/= str "") (vl-string-search "\\" str))
    (progn
      (if (setq regex (vlax-create-object "VBScript.RegExp"))
        (progn
          (vl-catch-all-apply
            '(lambda ()
               (vlax-put-property regex 'IgnoreCase :vlax-true)
               (vlax-put-property regex 'Global :vlax-true)
               ;; Strip formatting overrides {\f...; etc.}
               (vlax-put-property regex 'Pattern "\\\\[ACFHlOQUW][^;]*;|\\\\[a-z][0-9]*|[{}]")
               (setq str (vlax-invoke-method regex 'Replace str ""))
               ;; Replace \P with space
               (vlax-put-property regex 'Pattern "\\\\P")
               (setq str (vlax-invoke-method regex 'Replace str " "))
             )
          )
          (vlax-release-object regex)
        )
      )
    )
  )
  (if str (vl-string-trim " \t\r\n" str) "")
)

;;; -------------------------------------------------------------------------
;;; HELPER: Convert text into a valid AutoCAD attribute Tag
;;; Preserves exact case (no forced uppercase!) and replaces spaces with '_'
;;; -------------------------------------------------------------------------
(defun text-to-tag (str fallback-idx / cleanStr res i ch)
  (setq cleanStr (vl-string-trim " \t\r\n" str))
  (setq res "")
  (setq i 1)
  (while (<= i (strlen cleanStr))
    (setq ch (substr cleanStr i 1))
    (cond
      ;; Space or tab -> underscore
      ((or (= ch " ") (= ch "\t"))
       (if (and (/= res "") (/= (substr res (strlen res) 1) "_"))
         (setq res (strcat res "_"))
       )
      )
      ;; Allowed: a-z, A-Z, 0-9, _, -, . (Preserves original case!)
      ((or (and (>= ch "a") (<= ch "z"))
           (and (>= ch "A") (<= ch "Z"))
           (and (>= ch "0") (<= ch "9"))
           (= ch "_")
           (= ch "-")
           (= ch "."))
       (setq res (strcat res ch))
      )
      (t nil)
    )
    (setq i (1+ i))
  )

  ;; Trim trailing underscores
  (while (and (> (strlen res) 0) (= (substr res (strlen res) 1) "_"))
    (setq res (substr res 1 (1- (strlen res))))
  )

  ;; Fallback if string is empty
  (if (= res "")
    (setq res (strcat "ATT_" (itoa fallback-idx)))
  )

  ;; Limit length for AutoCAD tag safety
  (if (> (strlen res) 40)
    (setq res (substr res 1 40))
  )
  res
)

;;; -------------------------------------------------------------------------
;;; MAIN CONVERSION ENGINE
;;; -------------------------------------------------------------------------
(defun text2attr:main ( / acadObj doc oldEcho oldErr ss pickFirst total idx cnt
                          usedTags ent vla-ent objType ownerEname target rawTxt txt
                          ins insPoint height rot style lay col attach alignVal
                          scaleFactor oblique baseTag tag suffix attObj inBedit )

  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq inBedit (and (getvar "BLOCKEDITOR") (= (getvar "BLOCKEDITOR") 1)))
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  ;; Error handling
  (setq oldErr *error*)
  (defun *error* (msg)
    (if (and doc (= (vla-get-undoRecording doc) :vlax-true))
      (vla-EndUndoMark doc)
    )
    (if oldEcho (setvar "CMDECHO" oldEcho))
    (setq *error* oldErr)
    (if (and msg (not (wcmatch (strcase msg t) "*break*,*cancel*,*exit*")))
      (princ (strcat "\n⚠️ MT2ATT Error: " msg))
    )
    (princ)
  )

  ;; -------------------------------------------------------------------------
  ;; 1. Check for Pre-selection (BEFORE command enters)
  ;; -------------------------------------------------------------------------
  (setq pickFirst (ssget "_I"))
  (if (and pickFirst (> (sslength pickFirst) 0))
    (progn
      (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
      (sssetfirst nil nil) ; Clear grip highlight
    )
    ;; -----------------------------------------------------------------------
    ;; 2. Prompt for Selection (AFTER command enters)
    ;; -----------------------------------------------------------------------
    (progn
      (princ "\nSelect Text or MText object(s) to convert to Attribute(s) [Window/Crossing/Pick/ALL]: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    )
  )

  (if (or (null ss) (= (sslength ss) 0))
    (progn
      (princ "\n⚠️ No Text or MText objects selected.")
      (if oldEcho (setvar "CMDECHO" oldEcho))
      (setq *error* oldErr)
      (exit)
    )
  )

  (setq total (sslength ss))
  (setq usedTags '())

  ;; Start Undo Mark
  (vla-StartUndoMark doc)

  (setq idx 0)
  (setq cnt 1)

  (while (< idx total)
    (setq ent     (ssname ss idx))
    (setq vla-ent (vlax-ename->vla-object ent))
    (setq objType (vla-get-ObjectName vla-ent))

    ;; Detect owning block container (ModelSpace, PaperSpace, or BEDIT block)
    (setq ownerEname (cdr (assoc 330 (entget ent))))
    (if ownerEname
      (setq target (vlax-ename->vla-object ownerEname))
      (setq target (vla-get-Block (vla-get-ActiveLayout doc)))
    )

    ;; 1. Extract Text
    (setq rawTxt (vla-get-TextString vla-ent))
    (if (= objType "AcDbMText")
      (setq txt (clean-mtext-string rawTxt))
      (setq txt (vl-string-trim " \t\r\n" rawTxt))
    )

    ;; 2. Generate Tag from text content (preserving original case!)
    (setq baseTag (text-to-tag txt cnt))
    (setq tag baseTag)
    (setq suffix 1)
    ;; Prevent duplicate tags in the same block/drawing
    (while (member (strcase tag) usedTags)
      (setq suffix (1+ suffix))
      (setq tag (strcat baseTag "_" (itoa suffix)))
    )
    (setq usedTags (cons (strcase tag) usedTags))

    ;; 3. Extract Alignment & Coordinates
    (cond
      ;; --- Single-Line TEXT (AcDbText) ---
      ((= objType "AcDbText")
       (setq alignVal (vla-get-Alignment vla-ent))
       (if (= alignVal 0) ; Left alignment uses InsertionPoint
         (setq ins (vlax-variant-value (vla-get-InsertionPoint vla-ent)))
         (setq ins (vlax-variant-value (vla-get-TextAlignmentPoint vla-ent)))
       )
       (setq insPoint (vlax-safearray->list ins))
      )

      ;; --- Multi-Line MTEXT (AcDbMText) ---
      ((= objType "AcDbMText")
       (setq attach (vla-get-AttachmentPoint vla-ent))
       (setq alignVal
         (cond
           ((= attach 1) 6)   ; TopLeft
           ((= attach 2) 7)   ; TopCenter
           ((= attach 3) 8)   ; TopRight
           ((= attach 4) 9)   ; MiddleLeft
           ((= attach 5) 10)  ; MiddleCenter
           ((= attach 6) 11)  ; MiddleRight
           ((= attach 7) 12)  ; BottomLeft
           ((= attach 8) 13)  ; BottomCenter
           ((= attach 9) 14)  ; BottomRight
           (t 0)
         )
       )
       (setq ins (vlax-variant-value (vla-get-InsertionPoint vla-ent)))
       (setq insPoint (vlax-safearray->list ins))
      )
    )

    ;; 4. Extract Height
    (setq height (vla-get-Height vla-ent))
    (if (or (null height) (not (numberp height)) (<= height 0.0))
      (setq height (getvar "TEXTSIZE"))
    )
    (if (or (null height) (not (numberp height)) (<= height 0.0))
      (setq height 2.5)
    )

    ;; 5. Extract Rotation
    (setq rot (vla-get-Rotation vla-ent))
    (if (or (null rot) (not (numberp rot)))
      (setq rot 0.0)
    )

    ;; 6. Extract Style
    (setq style (vla-get-StyleName vla-ent))
    (if (or (null style) (= style ""))
      (setq style (getvar "TEXTSTYLE"))
    )

    ;; 7. Extract Layer
    (setq lay (vla-get-Layer vla-ent))

    ;; 8. Extract Color
    (setq col (vla-get-Color vla-ent))

    ;; 9. Extract Width Factor / Oblique (if available)
    (setq scaleFactor
      (if (vlax-property-available-p vla-ent 'ScaleFactor)
        (vla-get-ScaleFactor vla-ent)
        1.0
      )
    )
    (setq oblique
      (if (vlax-property-available-p vla-ent 'ObliqueAngle)
        (vla-get-ObliqueAngle vla-ent)
        0.0
      )
    )

    ;; 10. Create ATTDEF in the owning block/space
    ;; Prompt is set directly to 'tag' (clean, no "Enter ... :" preloaded prefix!)
    (setq attObj
      (vl-catch-all-apply
        'vla-AddAttribute
        (list
          target
          (float height)
          0                            ; acAttributeModeNormal
          tag                          ; Prompt -> clean, exactly matching tag!
          (vlax-3d-point insPoint)     ; Insertion point
          tag                          ; Tag Name (preserves original case!)
          txt                          ; Default Value
        )
      )
    )

    (if (vl-catch-all-error-p attObj)
      (princ (strcat "\n⚠️ Error creating attribute for: " tag))
      (progn
        ;; Set Layer, Style, Rotation, Color
        (vl-catch-all-apply 'vla-put-Layer (list attObj lay))
        (vl-catch-all-apply 'vla-put-StyleName (list attObj style))
        (vl-catch-all-apply 'vla-put-Rotation (list attObj rot))
        (if (and col (/= col 256))
          (vl-catch-all-apply 'vla-put-Color (list attObj col))
        )

        ;; Apply Width Factor & Oblique Angle
        (if (and scaleFactor (/= scaleFactor 1.0))
          (vl-catch-all-apply 'vla-put-ScaleFactor (list attObj scaleFactor))
        )
        (if (and oblique (/= oblique 0.0))
          (vl-catch-all-apply 'vla-put-ObliqueAngle (list attObj oblique))
        )

        ;; Match Exact Justification / Alignment Point
        (if (and alignVal (/= alignVal 0))
          (progn
            (vl-catch-all-apply 'vla-put-Alignment (list attObj alignVal))
            (vl-catch-all-apply 'vla-put-TextAlignmentPoint (list attObj (vlax-3d-point insPoint)))
          )
          (progn
            (vl-catch-all-apply 'vla-put-Alignment (list attObj 0))
            (vl-catch-all-apply 'vla-put-InsertionPoint (list attObj (vlax-3d-point insPoint)))
          )
        )

        (vla-Update attObj)

        ;; Delete the original Text / MText
        (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-Delete (list vla-ent)))
          (entdel ent)
        )

        (princ (strcat "\n-> Converted [" txt "] to Tag [" tag "]"))
        (setq cnt (1+ cnt))
      )
    )

    (setq idx (1+ idx))
  )

  ;; End Undo Mark
  (vla-EndUndoMark doc)

  (if oldEcho (setvar "CMDECHO" oldEcho))
  (setq *error* oldErr)

  (princ (strcat "\n✅ Successfully converted " (itoa (1- cnt)) " Text/MText object(s) to ATTDEF."))
  (if inBedit
    (princ "\n💡 Tip: After saving and exiting Block Editor, run ATTSYNC to update existing block references.")
  )
  (princ)
)

;;; -------------------------------------------------------------------------
;;; COMMAND DEFINITIONS
;;; -------------------------------------------------------------------------
(defun c:MT2ATT ()
  (text2attr:main)
)

(defun c:M2A ()
  (text2attr:main)
)

(defun c:T2A ()
  (text2attr:main)
)

(defun c:TXT2ATT ()
  (text2attr:main)
)

;;; -------------------------------------------------------------------------
;;; Load Notification
;;; -------------------------------------------------------------------------
(princ "\n📦 MTEXT2ATTR.lsp loaded successfully!")
(princ "\n   Type 'MT2ATT' or 'M2A' (or 'T2A') to convert Text/MText to Attributes.")
(princ "\n   (Preserves original case, clean prompt without 'Enter ... :')")
(princ)
