;;; =========================================================================
;;; ATTFIX.lsp - Attribute Synchronizer & Tag/Prompt/Value Unifier for AutoCAD
;;; =========================================================================
;;; 
;;; DESCRIPTION:
;;;   When modifying block attributes, AutoCAD typically requires manually
;;;   updating the Value, Tag, and Prompt separately (or diving into BEDIT
;;;   and dealing with destructive ATTSYNC resets).
;;;
;;;   ATTFIX solves this in one single step:
;;;   Pick any attribute, enter the new name/value, and ATTFIX automatically
;;;   updates ALL THREE components to that name:
;;;     1. Attribute Value   (TextString)  -> Updated to new name
;;;     2. Attribute Tag     (TagString)   -> Updated to new name (sanitized)
;;;     3. Attribute Prompt  (PromptString)-> Updated to new name in Block Def
;;;
;;;   Works on:
;;;     - Inserted Block References (Model Space & Paper Space / Layouts)
;;;     - Dynamic Blocks (*U anonymous block table records handled correctly)
;;;     - Attribute Definitions directly inside the BLOCK EDITOR (BEDIT)
;;;     - Preserves all custom attribute positions, rotations & formatting
;;;       WITHOUT running destructive ATTSYNC!
;;;
;;; COMMANDS:
;;;   ATTFIX    - Main command: Updates Value, Tag, & Prompt for selected attribute,
;;;               syncs Block Definition, and syncs Tags on all existing instances.
;;;   AF        - Fast keyboard shortcut for ATTFIX.
;;;   ATTFIXALL - Global mode: Same as ATTFIX, but ALSO updates the Value across
;;;               ALL instances of that block throughout the drawing.
;;;   AFA       - Fast keyboard shortcut for ATTFIXALL.
;;;
;;; =========================================================================

(vl-load-com)

;;; -------------------------------------------------------------------------
;;; HELPER: Sanitize string into a valid AutoCAD Attribute Tag
;;; (Replaces spaces/invalid symbols with underscores, converts to uppercase)
;;; -------------------------------------------------------------------------
(defun attfix:to-tag (str / res i ch cleanStr)
  (if (or (null str) (= str ""))
    "TAG"
    (progn
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
          ;; Allowed characters: A-Z, 0-9, _, -, .
          ((or (and (>= ch "A") (<= ch "Z"))
               (and (>= ch "0") (<= ch "9"))
               (= ch "_")
               (= ch "-")
               (= ch "."))
           (setq res (strcat res ch))
          )
          ;; Any other punctuation or symbol -> underscore
          (t
           (if (and (/= res "") (/= (substr res (strlen res) 1) "_"))
             (setq res (strcat res "_"))
           )
          )
        )
        (setq i (1+ i))
      )
      ;; Strip trailing underscores
      (while (and (> (strlen res) 0) (= (substr res (strlen res) 1) "_"))
        (setq res (substr res 1 (1- (strlen res))))
      )
      (if (= res "") "TAG" res)
    )
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
(defun attfix:update-block-def (doc blkName oldTag newTag newPrompt newVal / blks blkDef count)
  (setq count 0)
  (setq blks (vla-get-Blocks doc))
  (vl-catch-all-apply
    '(lambda ()
       (setq blkDef (vla-Item blks blkName))
       (vlax-for subObj blkDef
         (if (and (= (vla-get-ObjectName subObj) "AcDbAttributeDefinition")
                  (= (strcase (vla-get-TagString subObj)) (strcase oldTag)))
           (progn
             (vla-put-TagString subObj newTag)
             (vla-put-PromptString subObj newPrompt)
             (vla-put-TextString subObj newVal)
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
(defun attfix:sync-instances (doc blkName oldTag newTag newVal updateValueP / ss i ent bObj atts count)
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
                  (vla-put-TagString att newTag)
                  (if updateValueP
                    (vla-put-TextString att newVal)
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
;;; CORE FUNCTION: attfix:execute
;;; -------------------------------------------------------------------------
(defun attfix:execute (globalValueUpdate / acadObj doc oldEcho oldErr entPair ent entData entType
                                          attObj oldTag oldVal oldPrompt newName newTag newPrompt
                                          parentList parentEname blkRef blkName defCount instCount)
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

  (princ (strcat "\n" (if globalValueUpdate "🌐 [ATTFIXALL: Global Mode]" "⚡ [ATTFIX: Single Mode]")
                 " - Value, Tag & Prompt Synchronizer."))
  (princ "\nSelect an attribute to update (or press Enter/Esc to finish):")

  ;; Selection Loop
  (while (setq entPair (nentsel "\nSelect attribute: "))
    (setq ent (car entPair))
    (setq entData (entget ent))
    (setq entType (cdr (assoc 0 entData)))

    (cond
      ;; ---------------------------------------------------------------------
      ;; CASE 1: Attribute Reference (ATTRIB) on an inserted block
      ;; ---------------------------------------------------------------------
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

       (princ (strcat "\n📌 Found Attribute:"))
       (princ (strcat "\n   • Block : " blkName))
       (princ (strcat "\n   • Tag   : " oldTag))
       (princ (strcat "\n   • Value : \"" oldVal "\""))

       ;; Prompt for new text / name
       (setq newName (getstring t (strcat "\nEnter new Name/Value for Tag, Prompt & Value <" 
                                          (if (/= oldVal "") oldVal oldTag) ">: ")))
       (if (= newName "")
         (setq newName (if (/= oldVal "") oldVal oldTag))
       )

       (setq newTag (attfix:to-tag newName))
       (setq newPrompt newName)

       ;; 1. Update the picked attribute reference
       (vla-put-TextString attObj newName)
       (vla-put-TagString attObj newTag)
       (vla-Update attObj)
       (entupd ent)

       ;; 2. Update the parent block definition (ATTDEF)
       (setq defCount 0)
       (if (/= blkName "Unknown")
         (setq defCount (attfix:update-block-def doc blkName oldTag newTag newPrompt newName))
       )

       ;; 3. Synchronize existing instances in drawing
       (setq instCount 0)
       (if (/= blkName "Unknown")
         (setq instCount (attfix:sync-instances doc blkName oldTag newTag newName globalValueUpdate))
       )

       (vla-EndUndoMark doc)

       ;; Feedback
       (princ (strcat "\n✅ SUCCESS for Block [" blkName "]:"))
       (princ (strcat "\n   • Value  : \"" newName "\""))
       (princ (strcat "\n   • Tag    : " newTag))
       (princ (strcat "\n   • Prompt : \"" newPrompt "\""))
       (if (> defCount 0)
         (princ (strcat "\n   • Definition Updated: Tag & Prompt synced in Block Table."))
       )
       (if globalValueUpdate
         (princ (strcat "\n   • All Instances: " (itoa instCount) " block reference(s) updated with new Tag & Value."))
         (princ (strcat "\n   • Tag Sync: " (itoa instCount) " block reference(s) synced to Tag [" newTag "]."))
       )
      )

      ;; ---------------------------------------------------------------------
      ;; CASE 2: Attribute Definition (ATTDEF) in Block Editor or Model Space
      ;; ---------------------------------------------------------------------
      ((= entType "ATTDEF")
       (vla-StartUndoMark doc)
       (setq attObj (vlax-ename->vla-object ent))
       (setq oldTag (vla-get-TagString attObj))
       (setq oldPrompt (vla-get-PromptString attObj))
       (setq oldVal (vla-get-TextString attObj))

       (princ (strcat "\n📌 Found Attribute Definition (ATTDEF):"))
       (princ (strcat "\n   • Tag     : " oldTag))
       (princ (strcat "\n   • Prompt  : \"" oldPrompt "\""))
       (princ (strcat "\n   • Default : \"" oldVal "\""))

       ;; Prompt for new text / name
       (setq newName (getstring t (strcat "\nEnter new Name for Tag, Prompt & Default <" oldTag ">: ")))
       (if (= newName "") (setq newName oldTag))

       (setq newTag (attfix:to-tag newName))
       (setq newPrompt newName)

       ;; Update ATTDEF properties
       (vla-put-TagString attObj newTag)
       (vla-put-PromptString attObj newPrompt)
       (vla-put-TextString attObj newName)
       (vla-Update attObj)
       (entupd ent)

       (vla-EndUndoMark doc)

       (princ (strcat "\n✅ SUCCESS [ATTDEF Updated]:"))
       (princ (strcat "\n   • Tag     : " newTag))
       (princ (strcat "\n   • Prompt  : \"" newPrompt "\""))
       (princ (strcat "\n   • Default : \"" newName "\""))
      )

      ;; ---------------------------------------------------------------------
      ;; CASE 3: Not an attribute
      ;; ---------------------------------------------------------------------
      (t
       (princ (strcat "\n⚠️ Selected object is a [" entType "], not an attribute."))
       (princ "\n   Please click directly on an Attribute (ATTRIB or ATTDEF).")
      )
    )
  )

  (if oldEcho (setvar "CMDECHO" oldEcho))
  (setq *error* oldErr)
  (princ "\n🏁 ATTFIX completed.")
  (princ)
)

;;; -------------------------------------------------------------------------
;;; COMMAND: ATTFIX / AF (Single Attribute + Tag/Prompt Sync)
;;; -------------------------------------------------------------------------
(defun c:ATTFIX ()
  (attfix:execute nil)
)

(defun c:AF ()
  (attfix:execute nil)
)

;;; -------------------------------------------------------------------------
;;; COMMAND: ATTFIXALL / AFA (Global Value Update Across All Instances)
;;; -------------------------------------------------------------------------
(defun c:ATTFIXALL ()
  (attfix:execute t)
)

(defun c:AFA ()
  (attfix:execute t)
)

;;; -------------------------------------------------------------------------
;;; Load Notification
;;; -------------------------------------------------------------------------
(princ "\n📦 ATTFIX.lsp loaded successfully!")
(princ "\n   Type 'ATTFIX' or 'AF' to update attribute Value, Tag, & Prompt.")
(princ "\n   Type 'ATTFIXALL' or 'AFA' to also update Value across all block instances.")
(princ)
