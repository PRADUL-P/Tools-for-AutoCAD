;; =============================================================================
;; TWO_WAY_SYNC.LSP – True Two-Way Live Synchronizer for Numbers / Tags
;; =============================================================================
;; Features:
;;   - Two-Way live sync: edit EITHER side -> the other updates instantly.
;;   - Works with TEXT, MTEXT, ATTRIB, and BLOCKS with attributes.
;;   - Pairs 1-to-1 in natural physical order (Horizontal L->R, Vertical Top->Bottom).
;;   - Persistent: Saved in drawing XData, so links remain across saves/reopens.
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
;; Helper: Extract Insertion Point from entity
;; -----------------------------------------------------------------------------
(defun twoway:get-pt (vla-obj / typ atts)
  (setq typ (vla-get-ObjectName vla-obj))
  (cond
    ((member typ '("AcDbText" "AcDbMText" "AcDbBlockReference" "AcDbAttribute"))
     (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj)))
    )
    (t '(0.0 0.0 0.0))
  )
)

;; Coordinate accessors
(defun twoway:item-x (item) (car  (car item)))
(defun twoway:item-y (item) (cadr (car item)))

;; -----------------------------------------------------------------------------
;; Helper: Auto-sort a list of ((x y z) vla-obj) in natural reading order
;; -----------------------------------------------------------------------------
(defun twoway:sort-items (item-list / xs ys minX maxX minY maxY spanX spanY)
  (if (or (null item-list) (<= (length item-list) 1))
    item-list
    (progn
      (setq xs (mapcar 'twoway:item-x item-list))
      (setq ys (mapcar 'twoway:item-y item-list))
      (setq minX (apply 'min xs) maxX (apply 'max xs))
      (setq minY (apply 'min ys) maxY (apply 'max ys))
      (setq spanX (abs (- maxX minX)))
      (setq spanY (abs (- maxY minY)))

      (if (>= spanX spanY)
        ;; Horizontal dominant -> Left to Right (X ascending)
        (vl-sort item-list '(lambda (a b) (< (twoway:item-x a) (twoway:item-x b))))
        ;; Vertical dominant -> Top to Bottom (Y descending)
        (vl-sort item-list '(lambda (a b) (> (twoway:item-y a) (twoway:item-y b))))
      )
    )
  )
)

;; -----------------------------------------------------------------------------
;; Store and Retrieve Partner Handle safely using XData & LData
;; -----------------------------------------------------------------------------
(defun twoway:set-partner (vla-obj hPartner / ename elist)
  (setq ename (if (= (type vla-obj) 'VLA-OBJECT) (vlax-vla-object->ename vla-obj) vla-obj))
  ;; 1. Store in LData
  (vl-catch-all-apply 'vlax-ldata-put (list ename "TWOWAY_PARTNER" hPartner))
  ;; 2. Store in standard XData
  (if (not (tblsearch "APPID" "TWOWAYSYNC")) (regapp "TWOWAYSYNC"))
  (setq elist (list (list -3 (list "TWOWAYSYNC" (cons 1000 hPartner)))))
  (entmod (append (entget ename) elist))
)

(defun twoway:get-partner (vla-obj / ename res data xd)
  (setq ename (if (= (type vla-obj) 'VLA-OBJECT) (vlax-vla-object->ename vla-obj) vla-obj))
  ;; Try LData
  (setq res (vl-catch-all-apply 'vlax-ldata-get (list ename "TWOWAY_PARTNER")))
  (if (or (vl-catch-all-error-p res) (null res))
    ;; Fallback to XData
    (progn
      (setq data (entget ename '("TWOWAYSYNC")))
      (setq xd (assoc -3 data))
      (if xd
        (cdr (assoc 1000 (cdadr xd)))
        nil
      )
    )
    res
  )
)

;; -----------------------------------------------------------------------------
;; Reactor: On Object Modified
;; -----------------------------------------------------------------------------
(defun twoway:on-modified (notifier reactor params / doc hPartner tgtObj srcTxt tgtTxt)
  (if (not *twoway-is-syncing*)
    (progn
      (setq hPartner (twoway:get-partner notifier))
      (if hPartner
        (if (= (getvar "CMDNAMES") "")
          ;; Properties palette / direct modification
          (progn
            (setq *twoway-is-syncing* t)
            (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (setq srcTxt (twoway:get-text notifier))
                (setq tgtTxt (twoway:get-text tgtObj))
                (if (/= srcTxt tgtTxt)
                  (twoway:set-text tgtObj srcTxt)
                )
              )
            )
            (setq *twoway-is-syncing* nil)
          )
          ;; Inside an active command: queue for commandEnded
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
            (setq hPartner (twoway:get-partner srcObj))
            (if hPartner
              (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
              (setq tgtObj nil)
            )
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (setq srcTxt (twoway:get-text srcObj))
                (setq tgtTxt (twoway:get-text tgtObj))
                (if (/= srcTxt tgtTxt)
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
;; Reactor initialization
;; -----------------------------------------------------------------------------
(defun twoway:attach-reactor (vla-obj)
  (if (and vla-obj (not (vlax-object-released-p vla-obj)))
    (vlr-object-reactor (list vla-obj) "TWOWAY_SYNC"
      '((:vlr-modified . twoway:on-modified))
    )
  )
)

(if (not *twoway-cmd-reactor*)
  (setq *twoway-cmd-reactor*
    (vlr-command-reactor "TWOWAY_CMD"
      '((:vlr-commandEnded     . twoway:on-command-ended)
        (:vlr-commandCancelled . twoway:on-command-ended))
    )
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Pair two entities together
;; -----------------------------------------------------------------------------
(defun twoway:link-pair (objA objB / hA hB)
  (setq hA (vla-get-Handle objA))
  (setq hB (vla-get-Handle objB))

  (twoway:set-partner objA hB)
  (twoway:set-partner objB hA)

  (twoway:attach-reactor objA)
  (twoway:attach-reactor objB)

  ;; Handle nested block attributes
  (if (and (= (vla-get-ObjectName objA) "AcDbBlockReference")
           (= (vla-get-HasAttributes objA) :vlax-true))
    (foreach att (vlax-invoke objA 'GetAttributes)
      (twoway:set-partner att hB)
      (twoway:attach-reactor att)
    )
  )
  (if (and (= (vla-get-ObjectName objB) "AcDbBlockReference")
           (= (vla-get-HasAttributes objB) :vlax-true))
    (foreach att (vlax-invoke objB 'GetAttributes)
      (twoway:set-partner att hA)
      (twoway:attach-reactor att)
    )
  )
)

;; =============================================================================
;; COMMAND: TWOWAYSYNC (Batch Pair Two Groups 1-to-1)
;; =============================================================================
(defun c:TWOWAYSYNC ( / acadObj doc ss1 ss2 list1 list2 i ent vla-obj pt
                        count minCount objA objB txtA txtB )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (princ "\n=======================================================")
  (princ "\n TWOWAYSYNC: Two-Way Live Synchronizer")
  (princ "\n=======================================================")

  ;; 1. Select First Group
  (princ "\nSelect FIRST group of numbers: ")
  (setq ss1 (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

  (if (not ss1)
    (princ "\nNo objects selected. Exiting.")
    (progn
      (setq list1 '() i 0)
      (while (< i (sslength ss1))
        (setq ent (ssname ss1 i))
        (setq vla-obj (vlax-ename->vla-object ent))
        (setq pt (twoway:get-pt vla-obj))
        (setq list1 (cons (list pt vla-obj) list1))
        (setq i (1+ i))
      )

      ;; 2. Select Second Group
      (princ "\nSelect SECOND group of numbers: ")
      (setq ss2 (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

      (if (not ss2)
        (princ "\nNo objects selected for second group. Exiting.")
        (progn
          (setq list2 '() i 0)
          (while (< i (sslength ss2))
            (setq ent (ssname ss2 i))
            (setq vla-obj (vlax-ename->vla-object ent))
            (setq pt (twoway:get-pt vla-obj))
            (setq list2 (cons (list pt vla-obj) list2))
            (setq i (1+ i))
          )

          ;; 3. Sort both groups in their natural physical order
          ;; (Horizontal: Left->Right; Vertical: Top->Bottom)
          (setq list1 (twoway:sort-items list1))
          (setq list2 (twoway:sort-items list2))

          (setq minCount (min (length list1) (length list2)))
          (if (/= (length list1) (length list2))
            (princ (strcat "\nNotice: First group (" (itoa (length list1))
                           ") and Second group (" (itoa (length list2))
                           ") have different counts. Pairing first " (itoa minCount) " items."))
          )

          ;; 4. Pair 1-to-1 in order
          (vla-StartUndoMark doc)
          (setq count 0)
          (while (< count minCount)
            (setq objA (cadr (nth count list1)))
            (setq objB (cadr (nth count list2)))
            (setq txtA (twoway:get-text objA))
            (setq txtB (twoway:get-text objB))

            ;; Establish two-way link
            (twoway:link-pair objA objB)

            ;; Synchronize Group 2 to match Group 1's value if they differed
            (if (/= txtA txtB)
              (twoway:set-text objB txtA)
            )

            (princ (strcat "\n-> Paired Item #" (itoa (1+ count)) " [" txtA "]"))
            (setq count (1+ count))
          )
          (vla-EndUndoMark doc)

          (vla-Regen doc acAllViewports)
          (princ (strcat "\n\nSUCCESS: " (itoa count) " pair(s) are now in TRUE TWO-WAY LIVE SYNC!"))
          (princ "\nEdit ANY number in EITHER section -> the other updates immediately!")
        )
      )
    )
  )
  (princ)
)

;; =============================================================================
;; COMMAND: TWOWAY1 (Pair Two Items Click-by-Click)
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
            ;; Sync B to A initially
            (if (/= (twoway:get-text objA) (twoway:get-text objB))
              (twoway:set-text objB (twoway:get-text objA))
            )
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
  (setq count 0)

  (setq ss (ssget "_X" '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        (setq hPartner (twoway:get-partner obj))
        (if hPartner
          (progn
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
  (if (> count 0) (vla-Regen doc acAllViewports))
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
        (setq hPartner (twoway:get-partner obj))
        (if hPartner
          (progn
            (vl-catch-all-apply 'vlax-ldata-delete (list ent "TWOWAY_PARTNER"))
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (vl-catch-all-apply 'vlax-ldata-delete (list (vlax-vla-object->ename tgtObj) "TWOWAY_PARTNER"))
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

(princ "\n==================================================================")
(princ "\n TWO_WAY_SYNC Loaded!")
(princ "\n Run 'TWOWAYSYNC' to pair your horizontal & vertical sections.")
(princ "\n==================================================================\n")
(princ)