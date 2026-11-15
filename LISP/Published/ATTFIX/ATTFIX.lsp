;;; =========================================================================
;;; ATTFIX.lsp - Instant Batch Attribute Tag & Prompt Synchronizer
;;; =========================================================================
;;;
;;; DESCRIPTION:
;;;   Instantly updates block attribute TAGs and PROMPTs based on their
;;;   current VALUE "as it is"!
;;;
;;; FEATURES:
;;;   - Selection BEFORE command (Pre-selection / Pickfirst):
;;;       Select blocks/attributes first -> type AF -> INSTANT UPDATE!
;;;   - Selection AFTER command:
;;;       Type AF -> window-select, crossing, pick, or type ALL -> INSTANT UPDATE!
;;;   - Updates both the Attribute References (ATTRIB) and the parent
;;;     Block Definition (ATTDEF in Block Table Record).
;;;   - Also works directly on ATTDEF inside the Block Editor (BEDIT).
;;;   - 100% preserves custom attribute positions, rotations, and formatting
;;;     WITHOUT running destructive ATTSYNC!
;;;   - Single Undo Mark (Ctrl+Z reverses everything cleanly).
;;;
;;; COMMANDS:
;;;   ATTFIX / AF : Select any number of blocks/attributes to update instantly.
;;;
;;; =========================================================================

(vl-load-com)

;;; -------------------------------------------------------------------------
;;; HELPER: Safe Tag Assignment
;;; Sets TagString directly "as it is". If AutoCAD rejects spaces in TagString,
;;; gracefully falls back to replacing spaces with underscores.
;;; -------------------------------------------------------------------------
(defun attfix:set-tag-safe (obj newTag / err)
  (setq err (vl-catch-all-apply 'vla-put-TagString (list obj newTag)))
  (if (vl-catch-all-error-p err)
    (vl-catch-all-apply 'vla-put-TagString (list obj (vl-string-translate " " "_" newTag)))
  )
)

;;; -------------------------------------------------------------------------
;;; HELPER: Retrieve effective block name (supporting dynamic blocks)
;;; -------------------------------------------------------------------------
(defun attfix:get-block-name (blkRef)
  (cond
    ((vlax-property-available-p blkRef 'EffectiveName)
     (vla-get-EffectiveName blkRef))
    ((vlax-property-available-p blkRef 'Name)
     (vla-get-Name blkRef))
    (t nil)
  )
)

;;; -------------------------------------------------------------------------
;;; HELPER: Update Attribute Definition (ATTDEF) inside Block Table Record
;;; -------------------------------------------------------------------------
(defun attfix:update-block-def (doc blkName targetTag newVal / blks blkDef count)
  (setq count 0)
  (setq blks (vla-get-Blocks doc))
  (vl-catch-all-apply
    '(lambda ()
       (setq blkDef (vla-Item blks blkName))
       (vlax-for subObj blkDef
         (if (and (= (vla-get-ObjectName subObj) "AcDbAttributeDefinition")
                  (or (= (strcase (vla-get-TagString subObj)) (strcase targetTag))
                      (= (strcase (vla-get-TagString subObj)) (strcase newVal))))
           (progn
             (attfix:set-tag-safe subObj newVal)
             (vl-catch-all-apply 'vla-put-PromptString (list subObj newVal))
             (vl-catch-all-apply 'vla-put-TextString (list subObj newVal))
             (setq count (1+ count))
           )
         )
       )
     )
  )
  count
)

;;; -------------------------------------------------------------------------
;;; MAIN FUNCTION: attfix:main
;;; -------------------------------------------------------------------------
(defun attfix:main ( / acadObj doc oldEcho oldErr ss pickFirst i ent entObj
                       objType blkName atts att val oldTag targetVal
                       blkCount attCount defCount hasUpdated)
  (setq acadObj (vlax-get-acad-object))
  (setq doc (vla-get-ActiveDocument acadObj))
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  ;; Error handling with Undo protection
  (setq oldErr *error*)
  (defun *error* (msg)
    (if (and doc (= (vla-get-undoRecording doc) :vlax-true))
      (vla-EndUndoMark doc)
    )
    (if oldEcho (setvar "CMDECHO" oldEcho))
    (setq *error* oldErr)
    (if (and msg (not (wcmatch (strcase msg t) "*break*,*cancel*,*exit*")))
      (princ (strcat "\n⚠️ ATTFIX Error: " msg))
    )
    (princ)
  )

  ;; -------------------------------------------------------------------------
  ;; 1. Check for Pre-selection (BEFORE command enters)
  ;; -------------------------------------------------------------------------
  (setq pickFirst (ssget "_I"))
  (if (and pickFirst (> (sslength pickFirst) 0))
    (progn
      ;; Filter pre-selected objects for INSERT and ATTDEF only
      (setq ss (ssget "_I" '((0 . "INSERT,ATTDEF"))))
      (sssetfirst nil nil) ; Clear active selection grips
    )
    ;; -----------------------------------------------------------------------
    ;; 2. Prompt for Selection (AFTER command enters)
    ;; -----------------------------------------------------------------------
    (progn
      (princ "\nSelect block(s) or attribute(s) to update [Window/Crossing/ALL/Pick]: ")
      (setq ss (ssget '((0 . "INSERT,ATTDEF"))))
    )
  )

  ;; If no valid entities selected, exit cleanly
  (if (or (null ss) (= (sslength ss) 0))
    (progn
      (princ "\n⚠️ No blocks with attributes or ATTDEFs selected.")
      (if oldEcho (setvar "CMDECHO" oldEcho))
      (setq *error* oldErr)
      (exit)
    )
  )

  ;; Start single Undo transaction
  (vla-StartUndoMark doc)

  (setq blkCount 0)
  (setq attCount 0)
  (setq defCount 0)

  ;; -------------------------------------------------------------------------
  ;; 3. Process all selected entities
  ;; -------------------------------------------------------------------------
  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq entObj (vlax-ename->vla-object ent))
    (setq objType (vla-get-ObjectName entObj))

    (cond
      ;; --- Block Reference (INSERT) ---
      ((= objType "AcDbBlockReference")
       (if (= (vla-get-HasAttributes entObj) :vlax-true)
         (progn
           (setq blkName (attfix:get-block-name entObj))
           (setq atts (vlax-invoke entObj 'GetAttributes))
           (setq hasUpdated nil)

           (foreach att atts
             (setq val (vla-get-TextString att))
             (setq oldTag (vla-get-TagString att))

             ;; Only process if value is not empty
             (if (and val (/= (vl-string-trim " \t\r\n" val) ""))
               (progn
                 (setq val (vl-string-trim " \t\r\n" val))

                 ;; 1. Update Attribute Tag to Value as it is
                 (attfix:set-tag-safe att val)
                 (vla-Update att)
                 (setq attCount (1+ attCount))
                 (setq hasUpdated t)

                 ;; 2. Update Block Definition's ATTDEF Tag & Prompt to Value as it is
                 (if blkName
                   (setq defCount (+ defCount (attfix:update-block-def doc blkName oldTag val)))
                 )
               )
             )
           )

           (if hasUpdated
             (setq blkCount (1+ blkCount))
           )
         )
       )
      )

      ;; --- Attribute Definition (ATTDEF) directly in BEDIT or drawing ---
      ((= objType "AcDbAttributeDefinition")
       (setq val (vla-get-TextString entObj))
       (if (and val (/= (vl-string-trim " \t\r\n" val) ""))
         (setq targetVal (vl-string-trim " \t\r\n" val))
         (if (/= (vla-get-PromptString entObj) "")
           (setq targetVal (vla-get-PromptString entObj))
           (setq targetVal (vla-get-TagString entObj))
         )
       )

       (if (and targetVal (/= targetVal ""))
         (progn
           (attfix:set-tag-safe entObj targetVal)
           (vl-catch-all-apply 'vla-put-PromptString (list entObj targetVal))
           (vl-catch-all-apply 'vla-put-TextString (list entObj targetVal))
           (vla-Update entObj)
           (setq attCount (1+ attCount))
           (setq blkCount (1+ blkCount))
         )
       )
      )
    )

    (setq i (1+ i))
  )

  ;; Close Undo group
  (vla-EndUndoMark doc)

  ;; Restore system settings
  (if oldEcho (setvar "CMDECHO" oldEcho))
  (setq *error* oldErr)

  ;; -------------------------------------------------------------------------
  ;; 4. Feedback Summary
  ;; -------------------------------------------------------------------------
  (princ "\n========================================================")
  (princ "\n✅ ATTFIX Completed Successfully:")
  (princ (strcat "\n   • Block(s) Processed   : " (itoa blkCount)))
  (princ (strcat "\n   • Attribute(s) Updated : " (itoa attCount) " (Tag & Prompt set to Value as it is)"))
  (if (> defCount 0)
    (princ (strcat "\n   • Block Definition(s)  : Tag & Prompt updated in Block Table"))
  )
  (princ "\n========================================================")
  (princ)
)

;;; -------------------------------------------------------------------------
;;; COMMAND ALIASES: ATTFIX and AF
;;; -------------------------------------------------------------------------
(defun c:ATTFIX ()
  (attfix:main)
)

(defun c:AF ()
  (attfix:main)
)

;;; -------------------------------------------------------------------------
;;; Load Notification
;;; -------------------------------------------------------------------------
(princ "\n📦 ATTFIX.lsp loaded successfully!")
(princ "\n   Type 'AF' or 'ATTFIX' to instantly update Tag & Prompt to Value.")
(princ "\n   (Supports selection before or after command enters!)")
(princ)
