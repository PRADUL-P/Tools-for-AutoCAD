;;; =========================================================================
;;; BLOCK_RENAMER.lsp - Fast Block Renaming Tool for AutoCAD
;;; =========================================================================
;;;
;;; DESCRIPTION:
;;;   A powerful, intuitive block renaming utility designed to replace the
;;;   clunky native RENAME dialog with fast, modern workflows:
;;;
;;;   FEATURES:
;;;     1. Click-to-Rename (Interactive Pick):
;;;        Click any block directly on screen -> enter new name -> renamed!
;;;     2. Pre-Selection (Pickfirst):
;;;        Select a block first -> run BRN -> enter new name!
;;;     3. Dynamic Block Safe:
;;;        Correctly detects master EffectiveName for anonymous (*U...) dynamic blocks.
;;;     4. Batch Find & Replace (F):
;;;        Search and replace text across block names (e.g., _OLD -> _NEW).
;;;     5. Batch Add Prefix (P):
;;;        Prepend a prefix to selected block definitions (e.g., ARCH_).
;;;     6. Batch Add Suffix (S):
;;;        Append a suffix to selected block definitions (e.g., _v2).
;;;     7. Collision & Validation Protection:
;;;        Prevents overwriting existing blocks and blocks invalid CAD characters.
;;;     8. Single Undo Mark:
;;;        Clean Ctrl+Z undo protection.
;;;
;;; COMMANDS:
;;;   BRN         - Main block rename command
;;;   BLOCKRENAME - Full command name
;;;   BNAME       - Fast alias
;;;
;;; =========================================================================

(vl-load-com)

;;; -------------------------------------------------------------------------
;;; HELPER: Check if a block name is valid in AutoCAD
;;; (Cannot contain \ / : * ? " < > | = or be empty)
;;; -------------------------------------------------------------------------
(defun brn:valid-name-p (str / invalidChars i ch ok)
  (if (or (null str) (= (vl-string-trim " \t\r\n" str) ""))
    nil
    (progn
      (setq invalidChars "\\/:*?\"<>|=")
      (setq ok t)
      (setq i 1)
      (while (and ok (<= i (strlen invalidChars)))
        (setq ch (substr invalidChars i 1))
        (if (vl-string-search ch str)
          (setq ok nil)
        )
        (setq i (1+ i))
      )
      ok
    )
  )
)

;;; -------------------------------------------------------------------------
;;; HELPER: Retrieve master EffectiveName (handles anonymous dynamic blocks)
;;; -------------------------------------------------------------------------
(defun brn:get-block-name (blkRef / blkName)
  (cond
    ((vlax-property-available-p blkRef 'EffectiveName)
     (vla-get-EffectiveName blkRef))
    ((vlax-property-available-p blkRef 'Name)
     (vla-get-Name blkRef))
    (t nil)
  )
)

;;; -------------------------------------------------------------------------
;;; HELPER: Replace all occurrences of a substring in a string
;;; -------------------------------------------------------------------------
(defun brn:replace-all (findStr replaceStr inStr / pos lenF)
  (setq lenF (strlen findStr))
  (if (or (= lenF 0) (= inStr ""))
    inStr
    (progn
      (while (setq pos (vl-string-search (strcase findStr) (strcase inStr)))
        (setq inStr
          (strcat
            (substr inStr 1 pos)
            replaceStr
            (substr inStr (+ pos lenF 1))
          )
        )
      )
      inStr
    )
  )
)

;;; -------------------------------------------------------------------------
;;; HELPER: Rename Block Table Record safely
;;; -------------------------------------------------------------------------
(defun brn:rename-block (doc oldName newName / blks blkDef err success)
  (setq success nil)
  (cond
    ;; Same name check
    ((= (strcase oldName) (strcase newName))
     (princ (strcat "\n⚠️ New name is identical to current name [" oldName "]. Skipping."))
    )
    ;; Target name already exists
    ((tblsearch "BLOCK" newName)
     (princ (strcat "\n⚠️ Cannot rename: A block named [" newName "] already exists in the drawing!"))
    )
    ;; Invalid characters
    ((not (brn:valid-name-p newName))
     (princ (strcat "\n⚠️ Invalid block name [" newName "]. Cannot contain \\ / : * ? \" < > | =."))
    )
    ;; Perform rename
    (t
     (setq blks (vla-get-Blocks doc))
     (setq err
       (vl-catch-all-apply
         '(lambda ()
            (setq blkDef (vla-Item blks oldName))
            (vla-put-Name blkDef newName)
          )
       )
     )
     ;; Fallback to command-line rename if ActiveX encounters lock
     (if (vl-catch-all-error-p err)
       (setq err
         (vl-catch-all-apply
           '(lambda ()
              (vl-cmdf "._-rename" "_block" oldName newName)
            )
         )
       )
     )

     (if (tblsearch "BLOCK" newName)
       (progn
         (setq success t)
         (princ (strcat "\n✅ Renamed: [" oldName "] ➜ [" newName "]"))
       )
       (princ (strcat "\n⚠️ Failed to rename block [" oldName "]."))
     )
    )
  )
  success
)

;;; -------------------------------------------------------------------------
;;; MODE: Batch Find & Replace across Block Names
;;; -------------------------------------------------------------------------
(defun brn:batch-find-replace (doc / findStr replStr blks count oldName newName)
  (setq findStr (getstring t "\nEnter text to FIND in block names: "))
  (if (or (null findStr) (= findStr ""))
    (princ "\nNo search text entered. Aborted.")
    (progn
      (setq replStr (getstring t "\nEnter replacement text: "))
      (setq blks (vla-get-Blocks doc))
      (setq count 0)

      (vlax-for b blks
        (setq oldName (vla-get-Name b))
        ;; Skip anonymous and layout blocks (*Paper_Space, *Model_Space, *U...)
        (if (and (not (wcmatch oldName "`**"))
                 (vl-string-search (strcase findStr) (strcase oldName)))
          (progn
            (setq newName (brn:replace-all findStr replStr oldName))
            (if (/= oldName newName)
              (if (brn:rename-block doc oldName newName)
                (setq count (1+ count))
              )
            )
          )
        )
      )
      (princ (strcat "\n🏁 Find & Replace Complete: " (itoa count) " block(s) renamed."))
    )
  )
)

;;; -------------------------------------------------------------------------
;;; MODE: Batch Add Prefix / Suffix to Selected Blocks
;;; -------------------------------------------------------------------------
(defun brn:batch-affix (doc isPrefix / ss tagStr blkNames i ent bObj bName count newName)
  (princ (strcat "\nSelect blocks to add " (if isPrefix "PREFIX" "SUFFIX") " [Window/Crossing/ALL/Pick]: "))
  (setq ss (ssget '((0 . "INSERT"))))
  (if (or (null ss) (= (sslength ss) 0))
    (princ "\n⚠️ No blocks selected.")
    (progn
      (setq tagStr (getstring t (strcat "\nEnter " (if isPrefix "PREFIX" "SUFFIX") " to add: ")))
      (if (or (null tagStr) (= tagStr ""))
        (princ "\nNo text entered. Aborted.")
        (progn
          ;; Collect unique block names from selection
          (setq blkNames '())
          (setq i 0)
          (while (< i (sslength ss))
            (setq ent (ssname ss i))
            (setq bObj (vlax-ename->vla-object ent))
            (setq bName (brn:get-block-name bObj))
            (if (and bName (not (wcmatch bName "`**")) (not (member bName blkNames)))
              (setq blkNames (cons bName blkNames))
            )
            (setq i (1+ i))
          )

          (setq count 0)
          (foreach bName blkNames
            (setq newName (if isPrefix (strcat tagStr bName) (strcat bName tagStr)))
            (if (brn:rename-block doc bName newName)
              (setq count (1+ count))
            )
          )
          (princ (strcat "\n🏁 Batch Complete: " (itoa count) " block(s) renamed."))
        )
      )
    )
  )
)

;;; -------------------------------------------------------------------------
;;; MAIN ENGINE: brn:main
;;; -------------------------------------------------------------------------
(defun brn:main ( / acadObj doc oldEcho oldErr pickFirst ent entObj oldName
                    newName loop opt )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
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
      (princ (strcat "\n⚠️ BRN Error: " msg))
    )
    (princ)
  )

  (vla-StartUndoMark doc)

  ;; -------------------------------------------------------------------------
  ;; 1. Check for Pre-Selection (Pickfirst)
  ;; -------------------------------------------------------------------------
  (setq pickFirst (ssget "_I" '((0 . "INSERT"))))
  (if (and pickFirst (> (sslength pickFirst) 0))
    (progn
      (setq ent (ssname pickFirst 0))
      (sssetfirst nil nil) ; Clear grip highlight
      (setq entObj (vlax-ename->vla-object ent))
      (setq oldName (brn:get-block-name entObj))

      (if (and oldName (not (wcmatch oldName "`**")))
        (progn
          (princ (strcat "\n📌 Selected Block: [" oldName "]"))
          (setq newName (getstring t (strcat "\nEnter new name for block <" oldName ">: ")))
          (setq newName (vl-string-trim " \t\r\n" newName))
          (if (and (/= newName "") (/= (strcase newName) (strcase oldName)))
            (brn:rename-block doc oldName newName)
          )
        )
        (princ "\n⚠️ Anonymous or invalid block selected.")
      )
    )

    ;; -----------------------------------------------------------------------
    ;; 2. Interactive Selection Loop & Batch Options
    ;; -----------------------------------------------------------------------
    (progn
      (princ "\n========================================================")
      (princ "\n🏷️ BLOCK RENAMER (BRN)")
      (princ "\n   • Click any block on screen to rename it.")
      (princ "\n   • Options: [F]ind & replace  |  Add [P]refix  |  Add [S]uffix")
      (princ "\n   • Press Enter or Esc when finished.")
      (princ "\n========================================================")

      (setq loop t)
      (while loop
        (initget "Find Prefix Suffix")
        (setq opt (entsel "\nSelect block to rename [Find/Prefix/Suffix] <or Enter to exit>: "))

        (cond
          ;; Enter pressed -> exit
          ((null opt)
           (setq loop nil)
          )

          ;; Option: Find & Replace
          ((= opt "Find")
           (brn:batch-find-replace doc)
          )

          ;; Option: Add Prefix
          ((= opt "Prefix")
           (brn:batch-affix doc t)
          )

          ;; Option: Add Suffix
          ((= opt "Suffix")
           (brn:batch-affix doc nil)
          )

          ;; Object clicked on screen
          ((listp opt)
           (setq ent (car opt))
           (if (= (cdr (assoc 0 (entget ent))) "INSERT")
             (progn
               (setq entObj (vlax-ename->vla-object ent))
               (setq oldName (brn:get-block-name entObj))

               (if (and oldName (not (wcmatch oldName "`**")))
                 (progn
                   (princ (strcat "\n📌 Block: [" oldName "]"))
                   (setq newName (getstring t (strcat "\nEnter new name for block <" oldName ">: ")))
                   (setq newName (vl-string-trim " \t\r\n" newName))
                   (if (and (/= newName "") (/= (strcase newName) (strcase oldName)))
                     (brn:rename-block doc oldName newName)
                   )
                 )
                 (princ "\n⚠️ Cannot rename anonymous block definition directly.")
               )
             )
             (princ "\n⚠️ Selected object is not a block reference.")
           )
          )
        )
      )
    )
  )

  (vla-EndUndoMark doc)
  (if oldEcho (setvar "CMDECHO" oldEcho))
  (setq *error* oldErr)
  (princ "\n🏁 BLOCK RENAMER completed.")
  (princ)
)

;;; -------------------------------------------------------------------------
;;; COMMAND DEFINITIONS
;;; -------------------------------------------------------------------------
(defun c:BRN ()
  (brn:main)
)

(defun c:BLOCKRENAME ()
  (brn:main)
)

(defun c:BNAME ()
  (brn:main)
)

;;; -------------------------------------------------------------------------
;;; Load Notification
;;; -------------------------------------------------------------------------
(princ "\n📦 BLOCK_RENAMER.lsp loaded successfully!")
(princ "\n   Type 'BRN' or 'BNAME' to rename blocks on screen or in batch.")
(princ "\n   (Supports click-to-rename, Find & Replace, Prefix, and Suffix!)")
(princ)
