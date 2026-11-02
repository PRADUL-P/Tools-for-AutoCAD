;; =============================================================================
;; TWO_WAY_SYNC.LSP – True Two-Way Live Synchronizer for Numbers / Tags
;; =============================================================================
;; Description:
;;   Creates a TRUE TWO-WAY (bidirectional) live sync between matching numbers
;;   or tags in different sections (e.g., horizontal section and vertical/diagonal).
;;
;;   Unlike one-way fields:
;;     - If you edit the number in the HORIZONTAL section -> VERTICAL updates!
;;     - If you edit the number in the VERTICAL section   -> HORIZONTAL updates!
;;     - Updates happen in REAL-TIME (no need to run REGEN).
;;     - Works with plain TEXT, MTEXT, and BLOCKS with attributes.
;;     - The link is saved permanently inside the DWG (XData / LData).
;;
;; Commands:
;;   TWOWAYSYNC  : Batch-pair two groups of numbers (matches by value 1..11
;;                 automatically so no sorting errors can occur!).
;;   TWOWAY1     : Pair two items one-by-one by clicking them.
;;   TWOWAYCLEAR : Unlink selected objects from two-way synchronization.
;;   SYNCALL     : Force an immediate sync check on all paired items.
;; =============================================================================

(vl-load-com)

;; Global state
(setq *twoway-queue* nil)
(setq *twoway-is-syncing* nil)

;; -----------------------------------------------------------------------------
;; Helper: Extract text value from Text, MText, Attrib, or Block
;; -----------------------------------------------------------------------------
(defun twoway:get-text (vla-obj / typ atts str)
  (if (or (null vla-obj) (vlax-object-released-p vla-obj))
    ""
    (progn
      (setq typ (vla-get-ObjectName vla-obj))
      (setq str
        (cond
          ((member typ '("AcDbText" "AcDbMText" "AcDbAttribute" "AcDbAttributeDefinition"))
           (vla-get-TextString vla-obj)
          )
          ((and (= typ "AcDbBlockReference") (= (vla-get-HasAttributes vla-obj) :vlax-true))
           (setq atts (vlax-invoke vla-obj 'GetAttributes))
           (if atts (vla-get-TextString (car atts)) "")
          )
          (t "")
        )
      )
      (if str (vl-string-trim " \t\r\n" str) "")
    )
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Set text value on Text, MText, Attrib, or Block
;; -----------------------------------------------------------------------------
(defun twoway:set-text (vla-obj val / typ atts)
  (if (and vla-obj (not (vlax-object-released-p vla-obj)))
    (progn
      (setq typ (vla-get-ObjectName vla-obj))
      (cond
        ((member typ '("AcDbText" "AcDbMText" "AcDbAttribute" "AcDbAttributeDefinition"))
         (vl-catch-all-apply 'vla-put-TextString (list vla-obj val))
         (vl-catch-all-apply 'vla-Update (list vla-obj))
        )
        ((and (= typ "AcDbBlockReference") (= (vla-get-HasAttributes vla-obj) :vlax-true))
         (setq atts (vlax-invoke vla-obj 'GetAttributes))
         (if atts
           (progn
             (vl-catch-all-apply 'vla-put-TextString (list (car atts) val))
             (vl-catch-all-apply 'vla-Update (list (car atts)))
           )
         )
        )
      )
    )
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Extract position of entity (for spatial fallback)
;; -----------------------------------------------------------------------------
(defun twoway:get-pt (vla-obj / typ atts)
  (setq typ (vla-get-ObjectName vla-obj))
  (cond
    ((member typ '("AcDbText" "AcDbMText" "AcDbBlockReference"))
     (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj)))
    )
    ((= typ "AcDbAttribute")
     (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj)))
    )
    (t '(0.0 0.0 0.0))
  )
)

;; -----------------------------------------------------------------------------
;; Reactor: On Object Modified
;; -----------------------------------------------------------------------------
(defun twoway:on-modified (notifier reactor params / doc hPartner tgtObj srcTxt tgtTxt)
  (if (not *twoway-is-syncing*)
    (progn
      (setq hPartner (vlax-ldata-get notifier "TWOWAY_PARTNER"))
      (if hPartner
        (if (= (getvar "CMDNAMES") "")
          ;; Properties palette / direct edit outside command
          (progn
            (setq *twoway-is-syncing* t)
            (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (setq srcTxt (twoway:get-text notifier))
                (setq tgtTxt (twoway:get-text tgtObj))
                (if (and (/= srcTxt "") (/= srcTxt tgtTxt))
                  (twoway:set-text tgtObj srcTxt)
                )
              )
            )
            (setq *twoway-is-syncing* nil)
          )
          ;; Inside an active command (TEXTEDIT, EATTEDIT, DDEDIT): queue for commandEnded
          (if (not (member notifier *twoway-queue*))
            (setq *twoway-queue* (cons notifier *twoway-queue*))
          )
        )
      )
    )
  )
)

;; -----------------------------------------------------------------------------
;; Reactor: On Command Ended / Cancelled
;; -----------------------------------------------------------------------------
(defun twoway:on-command-ended (reactor params / doc srcObj hPartner tgtObj srcTxt tgtTxt)
  (if (and *twoway-queue* (not *twoway-is-syncing*))
    (progn
      (setq *twoway-is-syncing* t)
      (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
      (foreach srcObj *twoway-queue*
        (if (not (vlax-object-released-p srcObj))
          (progn
            (setq hPartner (vlax-ldata-get srcObj "TWOWAY_PARTNER"))
            (if hPartner
              (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
              (setq tgtObj nil)
            )
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (setq srcTxt (twoway:get-text srcObj))
                (setq tgtTxt (twoway:get-text tgtObj))
                (if (and (/= srcTxt "") (/= srcTxt tgtTxt))
                  (twoway:set-text tgtObj srcTxt)
                )
              )
            )
          )
        )
      )
      (setq *twoway-queue* nil)
      (setq *twoway-is-syncing* nil)
    )
  )
)

;; -----------------------------------------------------------------------------
;; Manage Object Reactors
;; -----------------------------------------------------------------------------
(defun twoway:attach-reactor (vla-obj)
  (if (and vla-obj (not (vlax-object-released-p vla-obj)))
    (vlr-object-reactor (list vla-obj) "TWOWAY_SYNC"
      '((:vlr-modified . twoway:on-modified))
    )
  )
)

;; Initialize Command Reactor
(if (not *twoway-cmd-reactor*)
  (setq *twoway-cmd-reactor*
    (vlr-command-reactor "TWOWAY_CMD"
      '((:vlr-commandEnded     . twoway:on-command-ended)
        (:vlr-commandCancelled . twoway:on-command-ended))
    )
  )
)

;; -----------------------------------------------------------------------------
;; Link Pair function
;; -----------------------------------------------------------------------------
(defun twoway:link-pair (objA objB / hA hB)
  (setq hA (vla-get-Handle objA))
  (setq hB (vla-get-Handle objB))

  ;; Store persistent cross-links in drawing
  (vlax-ldata-put objA "TWOWAY_PARTNER" hB)
  (vlax-ldata-put objB "TWOWAY_PARTNER" hA)

  ;; Attach live reactors
  (twoway:attach-reactor objA)
  (twoway:attach-reactor objB)

  ;; If objA or objB are blocks with attributes, link the attributes too
  (if (and (= (vla-get-ObjectName objA) "AcDbBlockReference")
           (= (vla-get-HasAttributes objA) :vlax-true))
    (foreach att (vlax-invoke objA 'GetAttributes)
      (vlax-ldata-put att "TWOWAY_PARTNER" hB)
      (twoway:attach-reactor att)
    )
  )
  (if (and (= (vla-get-ObjectName objB) "AcDbBlockReference")
           (= (vla-get-HasAttributes objB) :vlax-true))
    (foreach att (vlax-invoke objB 'GetAttributes)
      (vlax-ldata-put att "TWOWAY_PARTNER" hA)
      (twoway:attach-reactor att)
    )
  )
)

;; =============================================================================
;; COMMAND: TWOWAYSYNC (Batch Pair Two Groups with Smart Value Matching)
;; =============================================================================
(defun c:TWOWAYSYNC ( / acadObj doc ss1 ss2 list1 list2 i ent vla-obj
                        pairedA pairedB matchedPairs count txt1 txt2
                        objA objB rem1 rem2 spanX spanY )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (princ "\n=======================================================")
  (princ "\n TWOWAYSYNC: Two-Way Live Synchronizer")
  (princ "\n=======================================================")

  ;; 1. Select First Group
  (princ "\nSelect FIRST group of numbers (e.g. Horizontal section): ")
  (setq ss1 (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

  (if (not ss1)
    (princ "\nNo objects selected for first group. Exiting.")
    (progn
      ;; Build list1: (vla-obj)
      (setq list1 '() i 0)
      (while (< i (sslength ss1))
        (setq ent (ssname ss1 i))
        (setq list1 (cons (vlax-ename->vla-object ent) list1))
        (setq i (1+ i))
      )

      ;; 2. Select Second Group
      (princ "\nSelect SECOND group of numbers (e.g. Vertical/Diagonal section): ")
      (setq ss2 (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

      (if (not ss2)
        (princ "\nNo objects selected for second group. Exiting.")
        (progn
          ;; Build list2: (vla-obj)
          (setq list2 '() i 0)
          (while (< i (sslength ss2))
            (setq ent (ssname ss2 i))
            (setq list2 (cons (vlax-ename->vla-object ent) list2))
            (setq i (1+ i))
          )

          ;; 3. SMART VALUE MATCHING (1 to 1, 2 to 2 ... 11 to 11)
          ;; Matches objects whose current text strings are identical first!
          (setq matchedPairs '())
          (setq pairedA '() pairedB '())

          (foreach objA list1
            (setq txt1 (twoway:get-text objA))
            (if (/= txt1 "")
              (progn
                (setq objB nil)
                (foreach candidate list2
                  (if (and (null objB)
                           (not (member candidate pairedB))
                           (= (twoway:get-text candidate) txt1))
                    (setq objB candidate)
                  )
                )
                (if objB
                  (progn
                    (setq matchedPairs (cons (list objA objB txt1) matchedPairs))
                    (setq pairedA (cons objA pairedA))
                    (setq pairedB (cons objB pairedB))
                  )
                )
              )
            )
          )

          ;; Fallback for remaining items that didn't have identical initial text
          (setq rem1 (vl-remove-if '(lambda (x) (member x pairedA)) list1))
          (setq rem2 (vl-remove-if '(lambda (x) (member x pairedB)) list2))

          (if (and rem1 rem2)
            (progn
              ;; Sort remaining items spatially
              (setq rem1 (vl-sort rem1 '(lambda (a b) (< (car (twoway:get-pt a)) (car (twoway:get-pt b))))))
              (setq rem2 (vl-sort rem2 '(lambda (a b) (> (cadr (twoway:get-pt a)) (cadr (twoway:get-pt b))))))
              (setq count 0)
              (while (and (< count (length rem1)) (< count (length rem2)))
                (setq matchedPairs (cons (list (nth count rem1) (nth count rem2) "Spatial") matchedPairs))
                (setq count (1+ count))
              )
            )
          )

          ;; 4. Establish Two-Way Links
          (vla-StartUndoMark doc)
          (setq count 0)
          (foreach pair matchedPairs
            (twoway:link-pair (car pair) (cadr pair))
            (princ (strcat "\n-> Synced pair [" (caddr pair) "]"))
            (setq count (1+ count))
          )
          (vla-EndUndoMark doc)

          (princ (strcat "\n\nSUCCESS: " (itoa count) " pair(s) are now in TRUE TWO-WAY LIVE SYNC!"))
          (princ "\nEdit ANY number in EITHER section -> the other updates immediately!")
        )
      )
    )
  )
  (princ)
)

;; =============================================================================
;; COMMAND: TWOWAY1 (Pair Single Items Click-by-Click)
;; =============================================================================
(defun c:TWOWAY1 ( / acadObj doc pickA entA objA pickB entB objB loop )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq loop t)

  (princ "\n=======================================================")
  (princ "\n TWOWAY1: Pair Individual Items (Press Enter/ESC to stop)")
  (princ "\n=======================================================")

  (while loop
    (setq pickA (entsel "\nSelect FIRST item to pair (or press Enter to exit): "))
    (if (not pickA)
      (setq loop nil)
      (progn
        (setq entA (car pickA))
        (setq objA (vlax-ename->vla-object entA))
        (setq pickB (entsel "\nSelect SECOND item to pair with first: "))
        (if pickB
          (progn
            (setq entB (car pickB))
            (setq objB (vlax-ename->vla-object entB))
            (vla-StartUndoMark doc)
            (twoway:link-pair objA objB)
            (vla-EndUndoMark doc)
            (princ (strcat "\n-> Paired [" (twoway:get-text objA) "] <==> [" (twoway:get-text objB) "] in Two-Way Sync!"))
          )
        )
      )
    )
  )
  (princ "\nExited TWOWAY1.")
  (princ)
)

;; =============================================================================
;; COMMAND: SYNCALL (Force Immediate Refresh Across Drawing)
;; =============================================================================
(defun c:SYNCALL ( / acadObj doc ss i ent obj hPartner tgtObj srcTxt tgtTxt count )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (princ "\nScanning drawing for two-way synced objects...")

  (setq ss (ssget "_X" '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))
  (setq count 0)
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        (setq hPartner (vlax-ldata-get obj "TWOWAY_PARTNER"))
        (if hPartner
          (progn
            ;; Re-attach reactor if not active
            (twoway:attach-reactor obj)
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (setq srcTxt (twoway:get-text obj))
                (setq tgtTxt (twoway:get-text tgtObj))
                (if (and (/= srcTxt "") (/= srcTxt tgtTxt))
                  (progn
                    (twoway:set-text tgtObj srcTxt)
                    (setq count (1+ count))
                  )
                )
              )
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
  (vla-Regen doc acAllViewports)
  (princ (strcat "\nScan complete. Synchronized " (itoa count) " item(s)."))
  (princ)
)

;; =============================================================================
;; COMMAND: TWOWAYCLEAR (Remove Two-Way Sync from Selected Objects)
;; =============================================================================
(defun c:TWOWAYCLEAR ( / ss i ent obj hPartner tgtObj count doc )
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (princ "\nSelect objects to UNLINK from two-way sync: ")
  (setq ss (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))
  (if ss
    (progn
      (setq i 0 count 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        (setq hPartner (vlax-ldata-get obj "TWOWAY_PARTNER"))
        (if hPartner
          (progn
            (vlax-ldata-delete obj "TWOWAY_PARTNER")
            ;; Also clear partner's link
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (vlax-ldata-delete tgtObj "TWOWAY_PARTNER")
            )
            (setq count (1+ count))
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nUnlinked " (itoa count) " item(s)."))
    )
  )
  (princ)
)

;; Auto-scan drawing on load to ensure all existing pairs have reactors attached
(c:SYNCALL)

(princ "\n==================================================================")
(princ "\n TWO_WAY_SYNC Loaded!")
(princ "\n Commands:")
(princ "\n   TWOWAYSYNC  : Smart-match & pair two groups (e.g. 1-11 to 1-11)")
(princ "\n   TWOWAY1     : Click-by-click pairing")
(princ "\n   SYNCALL     : Refresh all pairs in the drawing")
(princ "\n   TWOWAYCLEAR : Unlink selected objects")
(princ "\n==================================================================\n")
(princ)