;;; =========================================================================
;;; ATTFIX.lsp - Instant Attribute Tag & Prompt Synchronizer for AutoCAD
;;; =========================================================================
;;; 
;;; DESCRIPTION:
;;;   Click any block attribute, and ATTFIX instantly changes its TAG and
;;;   PROMPT to match that attribute's VALUE exactly "as it is"!
;;;
;;;   What it does in 1 click:
;;;     1. Reads the selected attribute's current Value (e.g., "101" or "DOOR_A").
;;;     2. Sets Attribute Tag   (TagString)   -> to that Value as it is.
;;;     3. Sets Attribute Prompt (PromptString)-> to that Value as it is.
;;;     4. Synchronizes the parent Block Definition (ATTDEF in Block Table Record).
;;;     5. Synchronizes Tags across all existing block instances in the drawing.
;;;
;;;   Works on:
;;;     - Block References in Model Space and Paper Space / Layouts.
;;;     - Dynamic Blocks (correctly resolves *U anonymous blocks to EffectiveName).
;;;     - Attribute Definitions (ATTDEF) directly inside BLOCK EDITOR (BEDIT).
;;;     - Preserves all custom attribute positions, rotations, and formatting
;;;       WITHOUT running destructive ATTSYNC!
;;;
;;; COMMANDS:
;;;   ATTFIX    / AF  : 1-Click Sync Mode. Click any attribute to instantly change
;;;                     its Tag and Prompt to its Value as it is. Continuous loop!
;;;   ATTFIXEDIT/ AFE : Edit Mode. Pick attribute, type a new value, and Value,
;;;                     Tag, and Prompt all change to that new value as it is.
;;;   ATTFIXALL / AFA : Global Mode. Click attribute to sync Tag & Prompt to Value,
;;;                     AND updates that Value across ALL instances of that block.
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
(defun attfix:get-block-name (blkRef / blkName)
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
(defun attfix:update-block-def (doc blkName oldTag newVal / blks blkDef count)
  (setq count 0)
  (setq blks (vla-get-Blocks doc))
  (vl-catch-all-apply
    '(lambda ()
       (setq blkDef (vla-Item blks blkName))
       (vlax-for subObj blkDef
         (if (and (= (vla-get-ObjectName subObj) "AcDbAttributeDefinition")
                  (= (strcase (vla-get-TagString subObj)) (strcase oldTag)))
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
;;; HELPER: Synchronize existing block references across the drawing
;;; Always updates TagString to maintain consistency with definition.
;;; If updateValueP is T, also updates TextString (Value).
;;; -------------------------------------------------------------------------
(defun attfix:sync-instances (doc blkName oldTag newVal updateValueP / ss i ent bObj atts count)
  (setq count 0)
  (setq ss (ssget "_X" (list '(0 . "INSERT"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq bObj (vlax-ename->vla-object ent))
        (if (and (= (vla-get-ObjectName bObj) "AcDbBlockReference")
                 (= (strcase (attfix:get-block-name bObj)) (strcase blkName))
                 (= (vla-get-HasAttributes bObj) :vlax-true))
          (progn
            (setq atts (vlax-invoke bObj 'GetAttributes))
            (foreach att atts
              (if (= (strcase (vla-get-TagString att)) (strcase oldTag))
                (progn
                  (attfix:set-tag-safe att newVal)
                  (if updateValueP
                    (vl-catch-all-apply 'vla-put-TextString (list att newVal))
                  )
                  (vla-Update att)
                  (setq count (1+ count))
                )
              )
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
  count
)

;;; -------------------------------------------------------------------------
;;; CORE ENGINE: attfix:run
;;; -------------------------------------------------------------------------
(defun attfix:run (initialMode / acadObj doc oldEcho oldErr activeMode entPair ent
                                  entData entType attObj oldVal oldTag oldPrompt
                                  targetVal parentList parentEname blkRef blkName
                                  defCount instCount)
  (setq acadObj (vlax-get-acad-object))
  (setq doc (vla-get-ActiveDocument acadObj))
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
      (princ (strcat "\n⚠️ ATTFIX Error: " msg))
    )
    (princ "\n*Cancel*")
    (princ)
  )

  (setq activeMode initialMode)

  (princ "\n========================================================")
  (cond
    ((= activeMode 'SYNC)
     (princ "\n⚡ [ATTFIX] 1-Click Sync Mode:"))
    ((= activeMode 'EDIT)
     (princ "\n✏️ [ATTFIXEDIT] Edit & Sync Mode:"))
    ((= activeMode 'GLOBAL)
     (princ "\n🌐 [ATTFIXALL] Global All-Instances Mode:"))
  )
  (princ "\nClick any attribute -> Tag and Prompt will change to that value as it is!")
  (princ "\n[Press Enter or Esc when done | Options: E = Edit Value, G = Global All, S = 1-Click Sync]")
  (princ "\n========================================================")

  ;; Selection Loop
  (while
    (progn
      (initget "Edit Global Sync")
      (setq entPair (nentsel (strcat "\nSelect attribute to sync [" 
                                     (cond ((= activeMode 'SYNC) "1-Click Sync")
                                           ((= activeMode 'EDIT) "Edit Value")
                                           ((= activeMode 'GLOBAL) "Global All"))
                                     "] (or Enter to finish): ")))
    )

    ;; Check if user typed a keyword option
    (cond
      ((= entPair "Edit")
       (setq activeMode 'EDIT)
       (princ "\n✏️ Switched to Edit Mode. Pick an attribute to edit value and sync Tag/Prompt.")
      )
      ((= entPair "Global")
       (setq activeMode 'GLOBAL)
       (princ "\n🌐 Switched to Global Mode. Pick an attribute to sync across ALL block instances.")
      )
      ((= entPair "Sync")
       (setq activeMode 'SYNC)
       (princ "\n⚡ Switched to 1-Click Sync Mode. Click any attribute to sync Tag & Prompt to its Value as it is.")
      )

      ;; Entity picked
      ((listp entPair)
       (setq ent (car entPair))
       (setq entData (entget ent))
       (setq entType (cdr (assoc 0 entData)))

       (cond
         ;; ------------------------------------------------------------------
         ;; CASE 1: Attribute Reference (ATTRIB) on an inserted block
         ;; ------------------------------------------------------------------
         ((= entType "ATTRIB")
          (vla-StartUndoMark doc)
          (setq attObj (vlax-ename->vla-object ent))
          (setq oldVal (vla-get-TextString attObj))
          (setq oldTag (vla-get-TagString attObj))

          ;; Determine parent block
          (setq parentList (cadddr entPair))
          (setq parentEname (if parentList (last parentList) (cdr (assoc 330 entData))))
          (setq blkRef (if parentEname (vlax-ename->vla-object parentEname) nil))
          (setq blkName (if blkRef (attfix:get-block-name blkRef) "Unknown"))

          ;; Determine target value
          (if (= activeMode 'EDIT)
            ;; Edit Mode: ask user for new text
            (progn
              (setq targetVal (getstring t (strcat "\nEnter new Value for Block [" blkName "] <" oldVal ">: ")))
              (if (= targetVal "") (setq targetVal oldVal))
              (vla-put-TextString attObj targetVal)
            )
            ;; 1-Click Sync or Global Mode: use current value as it is!
            (progn
              (if (or (null oldVal) (= oldVal ""))
                (progn
                  (princ "\n⚠️ Current attribute value is empty.")
                  (setq targetVal (getstring t (strcat "\nEnter value for Tag & Prompt <" oldTag ">: ")))
                  (if (= targetVal "") (setq targetVal oldTag))
                  (vla-put-TextString attObj targetVal)
                )
                (setq targetVal oldVal)
              )
            )
          )

          ;; 1. Update the picked attribute's Tag directly to that value as it is
          (attfix:set-tag-safe attObj targetVal)
          (vla-Update attObj)
          (entupd ent)

          ;; 2. Update the parent block definition (ATTDEF)
          (setq defCount 0)
          (if (/= blkName "Unknown")
            (setq defCount (attfix:update-block-def doc blkName oldTag targetVal))
          )

          ;; 3. Synchronize existing instances in the drawing
          (setq instCount 0)
          (if (/= blkName "Unknown")
            (setq instCount (attfix:sync-instances doc blkName oldTag targetVal
                                                  (if (= activeMode 'GLOBAL) t nil)))
          )

          (vla-EndUndoMark doc)

          ;; Output feedback
          (princ (strcat "\n✅ SUCCESS for Block [" blkName "]:"))
          (princ (strcat "\n   • Value  : \"" (vla-get-TextString attObj) "\""))
          (princ (strcat "\n   • Tag    : \"" (vla-get-TagString attObj) "\" (changed to Value as it is)"))
          (princ (strcat "\n   • Prompt : \"" targetVal "\" (changed to Value as it is)"))
          (if (> defCount 0)
            (princ (strcat "\n   • Block Definition: ATTDEF Tag & Prompt updated in Block Table."))
          )
          (if (= activeMode 'GLOBAL)
            (princ (strcat "\n   • Global Sync: " (itoa instCount) " instance(s) updated with new Tag & Value."))
            (princ (strcat "\n   • Tag Sync: " (itoa instCount) " instance(s) synced to Tag \"" targetVal "\"."))
          )
         )

         ;; ------------------------------------------------------------------
         ;; CASE 2: Attribute Definition (ATTDEF) in Block Editor or Model Space
         ;; ------------------------------------------------------------------
         ((= entType "ATTDEF")
          (vla-StartUndoMark doc)
          (setq attObj (vlax-ename->vla-object ent))
          (setq oldTag (vla-get-TagString attObj))
          (setq oldPrompt (vla-get-PromptString attObj))
          (setq oldVal (vla-get-TextString attObj))

          ;; In ATTDEF, default text is in TextString
          (if (and (/= oldVal "") (/= activeMode 'EDIT))
            (setq targetVal oldVal)
            (if (/= oldTag "")
              (setq targetVal oldTag)
              (setq targetVal "TAG")
            )
          )

          (if (= activeMode 'EDIT)
            (progn
              (setq targetVal (getstring t (strcat "\nEnter new Name for Tag, Prompt & Default <" targetVal ">: ")))
              (if (= targetVal "") (setq targetVal oldVal))
            )
          )

          ;; Update ATTDEF properties to that value as it is
          (attfix:set-tag-safe attObj targetVal)
          (vl-catch-all-apply 'vla-put-PromptString (list attObj targetVal))
          (vl-catch-all-apply 'vla-put-TextString (list attObj targetVal))
          (vla-Update attObj)
          (entupd ent)

          (vla-EndUndoMark doc)

          (princ (strcat "\n✅ SUCCESS [ATTDEF in Block Editor]:"))
          (princ (strcat "\n   • Tag     : \"" targetVal "\" (changed to value as it is)"))
          (princ (strcat "\n   • Prompt  : \"" targetVal "\" (changed to value as it is)"))
          (princ (strcat "\n   • Default : \"" targetVal "\""))
         )

         ;; ------------------------------------------------------------------
         ;; CASE 3: Not an attribute
         ;; ------------------------------------------------------------------
         (t
          (princ (strcat "\n⚠️ Selected object is a [" entType "], not an attribute."))
          (princ "\n   Please click directly on an Attribute (ATTRIB or ATTDEF).")
         )
       )
      )
    )
  )

  (if oldEcho (setvar "CMDECHO" oldEcho))
  (setq *error* oldErr)
  (princ "\n🏁 ATTFIX completed.")
  (princ)
)

;;; -------------------------------------------------------------------------
;;; COMMAND: ATTFIX / AF (1-Click Instant Sync to Value as it is)
;;; -------------------------------------------------------------------------
(defun c:ATTFIX ()
  (attfix:run 'SYNC)
)

(defun c:AF ()
  (attfix:run 'SYNC)
)

;;; -------------------------------------------------------------------------
;;; COMMAND: ATTFIXEDIT / AFE (Edit Value first, then sync Tag & Prompt)
;;; -------------------------------------------------------------------------
(defun c:ATTFIXEDIT ()
  (attfix:run 'EDIT)
)

(defun c:AFE ()
  (attfix:run 'EDIT)
)

;;; -------------------------------------------------------------------------
;;; COMMAND: ATTFIXALL / AFA (Sync Tag & Prompt, and update Value across ALL blocks)
;;; -------------------------------------------------------------------------
(defun c:ATTFIXALL ()
  (attfix:run 'GLOBAL)
)

(defun c:AFA ()
  (attfix:run 'GLOBAL)
)

;;; -------------------------------------------------------------------------
;;; Load Notification
;;; -------------------------------------------------------------------------
(princ "\n📦 ATTFIX.lsp loaded successfully!")
(princ "\n   Type 'AF' or 'ATTFIX' -> 1-Click: Tag & Prompt change to that Value as it is.")
(princ "\n   Type 'AFE'            -> Edit Mode: Enter new Value and sync.")
(princ "\n   Type 'AFA'            -> Global Mode: Sync across all block instances.")
(princ)
