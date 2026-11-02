;; MTEXT2ATTR.LSP – Convert MText to Attribute Definitions (ATTDEF)
;; Works in Model Space, Paper Space, and inside the BLOCK EDITOR (BEDIT)!
;; -----------------------------------------------------------------------------
;; Usage:
;;   1. Load the script: APPLOAD or (load "MTEXT2ATTR.lsp")
;;   2. Type MT2ATT at the AutoCAD command prompt.
;;   3. Select the MText object(s) you want to convert.
;;   4. The Tag is automatically generated from the MText's current text.
;;   5. The MText is converted into an ATTDEF in-place and removed.
;; -----------------------------------------------------------------------------

(vl-load-com)

;; Helper: Strip MText formatting codes (\f..., \P, etc.)
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

;; Helper: Convert text into a valid AutoCAD attribute Tag
;; (AutoCAD tags cannot have spaces or special punctuation)
(defun text-to-tag (str fallback-idx / cleanStr res i ch)
  (setq cleanStr (strcase (vl-string-trim " \t\r\n" str)))
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
      ;; Allowed: A-Z, 0-9, _, -, .
      ((or (and (>= ch "A") (<= ch "Z"))
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

(defun c:MT2ATT ( / acadObj doc ss total idx cnt usedTags
                    ent vla-ent ownerEname target rawTxt txt ins insPoint
                    height rot style lay col attach baseTag tag suffix
                    attObj alignVal inBedit )

  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq inBedit (and (getvar "BLOCKEDITOR") (= (getvar "BLOCKEDITOR") 1)))

  (princ "\nSelect MText object(s) to convert to attribute(s): ")
  (setq ss (ssget '((0 . "MTEXT"))))

  (if (not ss)
    (princ "\nNo MText objects selected.")
    (progn
      (setq total (sslength ss))
      (setq usedTags '())

      ;; Start Undo Mark
      (vla-StartUndoMark doc)

      (setq idx 0)
      (setq cnt 1)

      (while (< idx total)
        (setq ent     (ssname ss idx))
        (setq vla-ent (vlax-ename->vla-object ent))

        ;; Detect the exact block container owning this entity
        ;; (Works automatically in Model Space, Paper Space, and Block Editor)
        (setq ownerEname (cdr (assoc 330 (entget ent))))
        (if ownerEname
          (setq target (vlax-ename->vla-object ownerEname))
          (setq target (vla-get-Block (vla-get-ActiveLayout doc)))
        )

        ;; 1. Extract Text
        (setq rawTxt (vla-get-TextString vla-ent))
        (setq txt (clean-mtext-string rawTxt))

        ;; 2. Generate Tag from MText content
        (setq baseTag (text-to-tag txt cnt))
        (setq tag baseTag)
        (setq suffix 1)
        ;; Prevent duplicate tags in the same block
        (while (member tag usedTags)
          (setq suffix (1+ suffix))
          (setq tag (strcat baseTag "_" (itoa suffix)))
        )
        (setq usedTags (cons tag usedTags))

        ;; 3. Extract Insertion Point
        (setq ins (vlax-variant-value (vla-get-InsertionPoint vla-ent)))
        (setq insPoint (vlax-safearray->list ins))

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

        ;; 9. Extract Attachment Point
        (setq attach (vla-get-AttachmentPoint vla-ent))

        ;; 10. Create ATTDEF in the owning block/space
        (setq attObj
          (vl-catch-all-apply
            'vla-AddAttribute
            (list
              target
              (float height)
              0                            ; acAttributeModeNormal
              (strcat "Enter " tag ":")    ; Prompt
              (vlax-3d-point insPoint)     ; Insertion point
              tag                          ; Tag Name (from text!)
              txt                          ; Default Value
            )
          )
        )

        (if (vl-catch-all-error-p attObj)
          (princ (strcat "\nError creating attribute for: " tag))
          (progn
            ;; Set Layer, Style, Rotation
            (vl-catch-all-apply 'vla-put-Layer (list attObj lay))
            (vl-catch-all-apply 'vla-put-StyleName (list attObj style))
            (vl-catch-all-apply 'vla-put-Rotation (list attObj rot))
            (if (and col (/= col 256))
              (vl-catch-all-apply 'vla-put-Color (list attObj col))
            )

            ;; Match MText Justification
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
                (t nil)
              )
            )

            (if alignVal
              (progn
                (vl-catch-all-apply 'vla-put-Alignment (list attObj alignVal))
                (vl-catch-all-apply 'vla-put-TextAlignmentPoint (list attObj (vlax-3d-point insPoint)))
              )
            )

            (vla-Update attObj)

            ;; Delete the original MText
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

      (princ (strcat "\nSuccessfully converted " (itoa (1- cnt)) " MText object(s) to ATTDEF."))
      (if inBedit
        (princ "\nTip: After saving and exiting Block Editor, run ATTSYNC to update existing block references.")
      )
    )
  )
  (princ)
)

(princ "\nMT2ATT loaded. Type MT2ATT to convert MText to Attributes.\n")
(princ)