;; =============================================================================
;; TWO_WAY_SYNC.LSP – True Two-Way Live Synchronizer for Specific Attributes
;; =============================================================================
;; Supports blocks with MULTIPLE attributes by letting you target the exact
;; attribute tag (e.g. NUM, TAG, ID) or auto-detecting the number attribute!
;; =============================================================================

(vl-load-com)

;; Global state
(setq *twoway-queue* nil)
(setq *twoway-is-syncing* nil)
(setq *twoway-last-tag* nil)

;; -----------------------------------------------------------------------------
;; Helper: Extract specific attribute from a block by Tag name or auto-detect
;; -----------------------------------------------------------------------------
(defun twoway:get-specific-att (blkObj targetTag / atts found)
  (if (and (= (vla-get-ObjectName blkObj) "AcDbBlockReference")
           (= (vla-get-HasAttributes blkObj) :vlax-true))
    (progn
      (setq atts (vlax-invoke blkObj 'GetAttributes))
      (cond
        ;; 1. User specified a tag name
        ((and targetTag (/= targetTag ""))
         (foreach a atts
           (if (= (strcase (vla-get-TagString a)) (strcase targetTag))
             (setq found a)
           )
         )
        )
        ;; 2. Only 1 attribute in block
        ((= (length atts) 1)
         (setq found (car atts))
        )
        ;; 3. Multiple attributes: find the attribute with numeric value
        (t
         (foreach a atts
           (if (and (null found)
                    (wcmatch (vl-string-trim " \t\r\n" (vla-get-TextString a)) "*#*"))
             (setq found a)
           )
         )
         (if (null found) (setq found (car atts)))
        )
      )
      found
    )
    nil
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Get list of all attribute tags in a block
;; -----------------------------------------------------------------------------
(defun twoway:list-tags (blkObj / atts tagList)
  (if (and (= (vla-get-ObjectName blkObj) "AcDbBlockReference")
           (= (vla-get-HasAttributes blkObj) :vlax-true))
    (progn
      (setq atts (vlax-invoke blkObj 'GetAttributes))
      (setq tagList (mapcar 'vla-get-TagString atts))
    )
    nil
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Extract text value from Text, MText, Attrib, or Block
;; -----------------------------------------------------------------------------
(defun twoway:get-text (vla-obj targetTag / typ att str)
  (if (or (null vla-obj) (vlax-object-released-p vla-obj))
    ""
    (progn
      (setq typ (vla-get-ObjectName vla-obj))
      (setq str
        (cond
          ((member typ '("AcDbText" "AcDbMText" "AcDbAttribute" "AcDbAttributeDefinition"))
           (vla-get-TextString vla-obj)
          )
          ((= typ "AcDbBlockReference")
           (setq att (twoway:get-specific-att vla-obj targetTag))
           (if att (vla-get-TextString att) "")
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
(defun twoway:set-text (vla-obj targetTag val / typ att)
  (if (and vla-obj (not (vlax-object-released-p vla-obj)))
    (progn
      (setq typ (vla-get-ObjectName vla-obj))
      (cond
        ((member typ '("AcDbText" "AcDbMText" "AcDbAttribute" "AcDbAttributeDefinition"))
         (vl-catch-all-apply 'vla-put-TextString (list vla-obj val))
         (vl-catch-all-apply 'vla-Update (list vla-obj))
        )
        ((= typ "AcDbBlockReference")
         (setq att (twoway:get-specific-att vla-obj targetTag))
         (if att
           (progn
             (vl-catch-all-apply 'vla-put-TextString (list att val))
             (vl-catch-all-apply 'vla-Update (list att))
           )
         )
        )
      )
    )
  )
)

;; Coordinate accessors
(defun twoway:item-x (item) (car  (car item)))
(defun twoway:item-y (item) (cadr (car item)))

;; Helper: Auto-sort in natural reading order
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
(defun twoway:set-partner (vla-obj hPartner tagTarget / ename elist)
  (setq ename (if (= (type vla-obj) 'VLA-OBJECT) (vlax-vla-object->ename vla-obj) vla-obj))
  (vl-catch-all-apply 'vlax-ldata-put (list ename "TWOWAY_PARTNER" hPartner))
  (if tagTarget
    (vl-catch-all-apply 'vlax-ldata-put (list ename "TWOWAY_TAG" tagTarget))
  )
  (if (not (tblsearch "APPID" "TWOWAYSYNC")) (regapp "TWOWAYSYNC"))
  (setq elist (list (list -3 (list "TWOWAYSYNC" (cons 1000 hPartner)))))
  (entmod (append (entget ename) elist))
)

(defun twoway:get-partner (vla-obj / ename res data xd)
  (setq ename (if (= (type vla-obj) 'VLA-OBJECT) (vlax-vla-object->ename vla-obj) vla-obj))
  (setq res (vl-catch-all-apply 'vlax-ldata-get (list ename "TWOWAY_PARTNER")))
  (if (or (vl-catch-all-error-p res) (null res))
    (progn
      (setq data (entget ename '("TWOWAYSYNC")))
      (setq xd (assoc -3 data))
      (if xd (cdr (assoc 1000 (cdadr xd))) nil)
    )
    res
  )
)

(defun twoway:get-stored-tag (vla-obj / ename res)
  (setq ename (if (= (type vla-obj) 'VLA-OBJECT) (vlax-vla-object->ename vla-obj) vla-obj))
  (setq res (vl-catch-all-apply 'vlax-ldata-get (list ename "TWOWAY_TAG")))
  (if (vl-catch-all-error-p res) nil res)
)

;; -----------------------------------------------------------------------------
;; Reactor: On Object Modified
;; -----------------------------------------------------------------------------
(defun twoway:on-modified (notifier reactor params / doc hPartner tgtObj srcTxt tgtTxt tagTgt tagSrc)
  (if (not *twoway-is-syncing*)
    (progn
      (setq hPartner (twoway:get-partner notifier))
      (if hPartner
        (if (= (getvar "CMDNAMES") "")
          (progn
            (setq *twoway-is-syncing* t)
            (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (setq tagSrc (twoway:get-stored-tag notifier))
                (setq tagTgt (twoway:get-stored-tag tgtObj))
                (setq srcTxt (twoway:get-text notifier tagSrc))
                (setq tgtTxt (twoway:get-text tgtObj tagTgt))
                (if (/= srcTxt tgtTxt)
                  (twoway:set-text tgtObj tagTgt srcTxt)
                )
              )
            )
            (setq *twoway-is-syncing* nil)
          )
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
(defun twoway:on-command-ended (reactor params / doc srcObj hPartner tgtObj srcTxt tgtTxt tagTgt tagSrc)
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
                (setq tagSrc (twoway:get-stored-tag srcObj))
                (setq tagTgt (twoway:get-stored-tag tgtObj))
                (setq srcTxt (twoway:get-text srcObj tagSrc))
                (setq tgtTxt (twoway:get-text tgtObj tagTgt))
                (if (/= srcTxt tgtTxt)
                  (twoway:set-text tgtObj tagTgt srcTxt)
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
;; Reactor Registration
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
;; Helper: Link two specific entities/attributes
;; -----------------------------------------------------------------------------
(defun twoway:link-pair (objA objB tagA tagB / hA hB attA attB)
  (setq hA (vla-get-Handle objA))
  (setq hB (vla-get-Handle objB))

  (twoway:set-partner objA hB tagB)
  (twoway:set-partner objB hA tagA)

  (twoway:attach-reactor objA)
  (twoway:attach-reactor objB)

  ;; If objA is a block, attach reactor directly to the target attribute
  (if (= (vla-get-ObjectName objA) "AcDbBlockReference")
    (progn
      (setq attA (twoway:get-specific-att objA tagA))
      (if attA
        (progn
          (twoway:set-partner attA hB tagB)
          (twoway:attach-reactor attA)
        )
      )
    )
  )

  ;; If objB is a block, attach reactor directly to the target attribute
  (if (= (vla-get-ObjectName objB) "AcDbBlockReference")
    (progn
      (setq attB (twoway:get-specific-att objB tagB))
      (if attB
        (progn
          (twoway:set-partner attB hA tagA)
          (twoway:attach-reactor attB)
        )
      )
    )
  )
)

;; =============================================================================
;; COMMAND: TWOWAYSYNC (Batch Pair Two Groups with Attribute Tag Selection)
;; =============================================================================
(defun c:TWOWAYSYNC ( / acadObj doc ss1 ss2 list1 list2 i ent vla-obj pt
                        count minCount objA objB txtA txtB sampleBlk detectedTags
                        tagPrompt userTag )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (princ "\n=======================================================")
  (princ "\n TWOWAYSYNC: Two-Way Live Synchronizer")
  (princ "\n=======================================================")

  ;; 1. Select First Group
  (princ "\nSelect FIRST group of numbers (Horizontal): ")
  (setq ss1 (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

  (if (not ss1)
    (princ "\nNo objects selected. Exiting.")
    (progn
      (setq list1 '() i 0 sampleBlk nil)
      (while (< i (sslength ss1))
        (setq ent (ssname ss1 i))
        (setq vla-obj (vlax-ename->vla-object ent))
        (setq pt (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj))))
        (setq list1 (cons (list pt vla-obj) list1))
        (if (and (null sampleBlk) (= (vla-get-ObjectName vla-obj) "AcDbBlockReference"))
          (setq sampleBlk vla-obj)
        )
        (setq i (1+ i))
      )

      ;; 2. Select Second Group
      (princ "\nSelect SECOND group of numbers (Vertical): ")
      (setq ss2 (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

      (if (not ss2)
        (princ "\nNo objects selected for second group. Exiting.")
        (progn
          (setq list2 '() i 0)
          (while (< i (sslength ss2))
            (setq ent (ssname ss2 i))
            (setq vla-obj (vlax-ename->vla-object ent))
            (setq pt (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj))))
            (setq list2 (cons (list pt vla-obj) list2))
            (if (and (null sampleBlk) (= (vla-get-ObjectName vla-obj) "AcDbBlockReference"))
              (setq sampleBlk vla-obj)
            )
            (setq i (1+ i))
          )

          ;; Check for multiple attributes in block
          (setq userTag nil)
          (if sampleBlk
            (progn
              (setq detectedTags (twoway:list-tags sampleBlk))
              (if (and detectedTags (> (length detectedTags) 1))
                (progn
                  (princ (strcat "\nDetected Block Attribute Tags: [" (vl-string-trim " " (apply 'strcat (mapcar '(lambda (x) (strcat x " ")) detectedTags))) "]"))
                  (setq tagPrompt (strcase (getstring (strcat "\nEnter Attribute Tag to sync (or press Enter to auto-detect number attribute): "))))
                  (if (/= tagPrompt "") (setq userTag tagPrompt))
                )
              )
            )
          )

          ;; 3. Sort both groups naturally (Left->Right / Top->Bottom)
          (setq list1 (twoway:sort-items list1))
          (setq list2 (twoway:sort-items list2))

          (setq minCount (min (length list1) (length list2)))
          (if (/= (length list1) (length list2))
            (princ (strcat "\nNotice: First group (" (itoa (length list1))
                           ") and Second group (" (itoa (length list2))
                           ") counts differ. Pairing first " (itoa minCount) " items."))
          )

          ;; 4. Pair 1-to-1 in order
          (vla-StartUndoMark doc)
          (setq count 0)
          (while (< count minCount)
            (setq objA (cadr (nth count list1)))
            (setq objB (cadr (nth count list2)))
            (setq txtA (twoway:get-text objA userTag))
            (setq txtB (twoway:get-text objB userTag))

            (twoway:link-pair objA objB userTag userTag)

            ;; Synchronize initial value if differed
            (if (/= txtA txtB)
              (twoway:set-text objB userTag txtA)
            )

            (princ (strcat "\n-> Paired Item #" (itoa (1+ count)) " [" txtA "]"))
            (setq count (1+ count))
          )
          (vla-EndUndoMark doc)

          (vla-Regen doc acAllViewports)
          (princ (strcat "\n\nSUCCESS: " (itoa count) " pair(s) are now in TRUE TWO-WAY LIVE SYNC!"))
          (princ "\nEdit the number in EITHER section -> the other updates immediately!")
        )
      )
    )
  )
  (princ)
)

;; =============================================================================
;; COMMAND: TWOWAY1 (Pair Specific Attribute Click-by-Click)
;; Uses nentsel so you click directly on the exact attribute you want!
;; =============================================================================
(defun c:TWOWAY1 ( / acadObj doc pickA entA objA pickB entB objB loop txtA txtB )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq loop t)

  (princ "\n=======================================================")
  (princ "\n TWOWAY1: Click the EXACT attribute/text on each side")
  (princ "\n=======================================================")

  (while loop
    (setq pickA (nentsel "\nClick FIRST attribute/text (or press Enter to exit): "))
    (if (not pickA)
      (setq loop nil)
      (progn
        (setq entA (car pickA))
        (setq objA (vlax-ename->vla-object entA))
        (setq pickB (nentsel "\nClick SECOND attribute/text to pair: "))
        (if pickB
          (progn
            (setq entB (car pickB))
            (setq objB (vlax-ename->vla-object entB))
            (vla-StartUndoMark doc)
            (twoway:link-pair objA objB nil nil)
            (setq txtA (twoway:get-text objA nil))
            (setq txtB (twoway:get-text objB nil))
            (if (/= txtA txtB)
              (twoway:set-text objB nil txtA)
            )
            (vla-EndUndoMark doc)
            (princ (strcat "\n-> Paired [" txtA "] <==> [" txtB "] in Two-Way Sync!"))
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
(defun c:SYNCALL ( / acadObj doc ss i ent obj hPartner tgtObj srcTxt tgtTxt count tagSrc tagTgt )
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
                (setq tagSrc (twoway:get-stored-tag obj))
                (setq tagTgt (twoway:get-stored-tag tgtObj))
                (setq srcTxt (twoway:get-text obj tagSrc))
                (setq tgtTxt (twoway:get-text tgtObj tagTgt))
                (if (and (/= srcTxt "") (/= srcTxt tgtTxt))
                  (progn
                    (twoway:set-text tgtObj tagTgt srcTxt)
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
            (vl-catch-all-apply 'vlax-ldata-delete (list ent "TWOWAY_TAG"))
            (setq tgtObj (vl-catch-all-apply 'vla-HandleToObject (list doc hPartner)))
            (if (and tgtObj (not (vl-catch-all-error-p tgtObj)))
              (progn
                (vl-catch-all-apply 'vlax-ldata-delete (list (vlax-vla-object->ename tgtObj) "TWOWAY_PARTNER"))
                (vl-catch-all-apply 'vlax-ldata-delete (list (vlax-vla-object->ename tgtObj) "TWOWAY_TAG"))
              )
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
(princ "\n TWO_WAY_SYNC Loaded with Multi-Attribute Support!")
(princ "\n   TWOWAYSYNC : Batch sync (prompts for tag if block has multiple)")
(princ "\n   TWOWAY1    : Click directly on the specific attribute to link")
(princ "\n==================================================================\n")
(princ)