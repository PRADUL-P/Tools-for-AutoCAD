;; =============================================================================
;; LINK_TEXT.LSP – Dynamic Text & Attribute Linker for AutoCAD
;; =============================================================================
;; Description:
;;   Links numbers or text annotations across different sections (e.g., horizontal
;;   and vertical/diagonal sections) using native AutoCAD Dynamic Fields.
;;
;;   When you update any source text in the primary section, the linked copy in
;;   the other section updates AUTOMATICALLY upon REGEN, SAVE, or PLOT!
;;
;; Commands:
;;   LINKBATCH : Batch-links two series of numbers at once (e.g. 1-11 horizontal
;;               to 1-11 vertical). Auto-sorts Left-to-Right or Top-to-Bottom!
;;   LINK1     : Click any source text/attribute, then click target to link one-by-one.
;;   COPYLINK  : Click a source text/block and place a linked duplicate at a new point.
;; =============================================================================

(vl-load-com)

;; -----------------------------------------------------------------------------
;; Helper: Get 64-bit safe ObjectId String for AutoCAD Fields
;; -----------------------------------------------------------------------------
(defun lt:get-obj-id-str (vla-obj doc / util id)
  (setq util (vla-get-Utility doc))
  (if (vlax-method-applicable-p util 'GetObjectIdString)
    (vla-GetObjectIdString util vla-obj :vlax-false)
    (progn
      (setq id (vla-get-ObjectID vla-obj))
      (if (numberp id) (rtos id 2 0) (itoa id))
    )
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Extract target Text/MText/Attribute VLA-Object and its position
;; -----------------------------------------------------------------------------
(defun lt:get-text-vla-and-pt (ent / data typ vla-obj atts)
  (setq data (entget ent))
  (setq typ  (cdr (assoc 0 data)))
  (setq vla-obj (vlax-ename->vla-object ent))
  (cond
    ;; Standalone Text or MText
    ((member typ '("TEXT" "MTEXT" "ATTRIB"))
     (list (cdr (assoc 10 data)) vla-obj)
    )
    ;; Block reference with attributes
    ((and (= typ "INSERT") (= (vla-get-HasAttributes vla-obj) :vlax-true))
     (setq atts (vlax-invoke vla-obj 'GetAttributes))
     (if (and atts (> (length atts) 0))
       (list (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint (car atts))))
             (car atts)
       )
       nil
     )
    )
    (t nil)
  )
)

;; -----------------------------------------------------------------------------
;; Helper: Auto-sort a list of ((x y z) vla-obj) based on natural layout
;; -----------------------------------------------------------------------------
(defun lt:sort-entities (item-list / xs ys minX maxX minY maxY spanX spanY)
  (if (or (null item-list) (<= (length item-list) 1))
    item-list
    (progn
      (setq xs (mapcar 'caar item-list))
      (setq ys (mapcar 'cadar item-list))
      (setq minX (apply 'min xs) maxX (apply 'max xs))
      (setq minY (apply 'min ys) maxY (apply 'max ys))
      (setq spanX (abs (- maxX minX)))
      (setq spanY (abs (- maxY minY)))

      (if (>= spanX spanY)
        ;; Primarily Horizontal -> Sort Left-to-Right (X ascending)
        (vl-sort item-list '(lambda (a b) (< (caar a) (caar b))))
        ;; Primarily Vertical -> Sort Top-to-Bottom (Y descending)
        (vl-sort item-list '(lambda (a b) (> (cadar a) (cadar b))))
      )
    )
  )
)

;; =============================================================================
;; COMMAND 1: LINKBATCH (Batch-Link two series of tags)
;; Perfect for linking 1 to 11 in horizontal to 1 to 11 in vertical/diagonal!
;; =============================================================================
(defun c:LINKBATCH ( / acadObj doc ssSrc ssTgt srcList tgtList
                       i ent pair count minCount srcObj tgtObj srcId fieldStr )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (princ "\n=======================================================")
  (princ "\n LINKBATCH: Batch-Link Numbers Across Sections")
  (princ "\n=======================================================")

  ;; 1. Select Source Objects (e.g., horizontal section numbers)
  (princ "\nSelect SOURCE numbers (e.g. horizontal section 1 to 11): ")
  (setq ssSrc (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

  (if (not ssSrc)
    (princ "\nNo source objects selected. Exiting.")
    (progn
      ;; Build source list: ((pt vla-obj) ...)
      (setq srcList '() i 0)
      (while (< i (sslength ssSrc))
        (setq ent (ssname ssSrc i))
        (setq pair (lt:get-text-vla-and-pt ent))
        (if pair (setq srcList (cons pair srcList)))
        (setq i (1+ i))
      )

      ;; 2. Select Target Objects (e.g., vertical section numbers)
      (princ "\nSelect TARGET numbers to link (e.g. vertical section 1 to 11): ")
      (setq ssTgt (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

      (if (not ssTgt)
        (princ "\nNo target objects selected. Exiting.")
        (progn
          ;; Build target list: ((pt vla-obj) ...)
          (setq tgtList '() i 0)
          (while (< i (sslength ssTgt))
            (setq ent (ssname ssTgt i))
            (setq pair (lt:get-text-vla-and-pt ent))
            (if pair (setq tgtList (cons pair tgtList)))
            (setq i (1+ i))
          )

          ;; 3. Auto-sort both series
          (setq srcList (lt:sort-entities srcList))
          (setq tgtList (lt:sort-entities tgtList))

          (setq minCount (min (length srcList) (length tgtList)))

          (if (/= (length srcList) (length tgtList))
            (princ (strcat "\nNotice: Source count (" (itoa (length srcList))
                           ") differs from Target count (" (itoa (length tgtList))
                           "). Linking first " (itoa minCount) " items."))
          )

          ;; 4. Apply dynamic fields in a single undo transaction
          (vla-StartUndoMark doc)
          (setq count 0)
          (while (< count minCount)
            (setq srcObj (cadr (nth count srcList)))
            (setq tgtObj (cadr (nth count tgtList)))
            (setq srcId  (lt:get-obj-id-str srcObj doc))

            ;; Construct native AutoCAD Field referencing Source TextString
            (setq fieldStr (strcat "%<\\AcObjProp Object(%<\\_ObjId " srcId ">%).TextString>%"))

            ;; Write field into target
            (vl-catch-all-apply 'vla-put-TextString (list tgtObj fieldStr))
            (vl-catch-all-apply 'vla-Update (list tgtObj))

            (setq count (1+ count))
          )
          (vla-EndUndoMark doc)

          ;; 5. Regenerate drawing so fields display updated values immediately
          (vla-Regen doc acAllViewports)

          (princ (strcat "\nSuccessfully linked " (itoa count) " item(s)!"))
          (princ "\nWhenever you edit any source text, run REGEN to update the linked section.")
        )
      )
    )
  )
  (princ)
)

;; =============================================================================
;; COMMAND 2: LINK1 (Link one-by-one by clicking)
;; Click source text, then click target text. Loops until Enter/Esc.
;; =============================================================================
(defun c:LINK1 ( / acadObj doc nPickSrc srcEnt srcData srcTyp srcVla srcId
                   nPickTgt tgtEnt tgtData tgtTyp tgtVla fieldStr loop )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq loop t)

  (princ "\n=======================================================")
  (princ "\n LINK1: Single Text/Attribute Linker (Press ESC to stop)")
  (princ "\n=======================================================")

  (while loop
    (setq nPickSrc (nentsel "\nSelect SOURCE text/attribute (or press Enter to exit): "))
    (if (not nPickSrc)
      (setq loop nil)
      (progn
        (setq srcEnt  (car nPickSrc))
        (setq srcData (entget srcEnt))
        (setq srcTyp  (cdr (assoc 0 srcData)))
        (if (not (member srcTyp '("TEXT" "MTEXT" "ATTRIB")))
          (princ (strcat "\nSelected source is a " srcTyp ", not a text/attribute!"))
          (progn
            (setq srcVla (vlax-ename->vla-object srcEnt))
            (setq srcId  (lt:get-obj-id-str srcVla doc))

            (setq nPickTgt (nentsel "\nSelect TARGET text/attribute to receive link: "))
            (if nPickTgt
              (progn
                (setq tgtEnt  (car nPickTgt))
                (setq tgtData (entget tgtEnt))
                (setq tgtTyp  (cdr (assoc 0 tgtData)))
                (if (not (member tgtTyp '("TEXT" "MTEXT" "ATTRIB")))
                  (princ (strcat "\nSelected target is a " tgtTyp ", not a text/attribute!"))
                  (progn
                    (vla-StartUndoMark doc)
                    (setq tgtVla   (vlax-ename->vla-object tgtEnt))
                    (setq fieldStr (strcat "%<\\AcObjProp Object(%<\\_ObjId " srcId ">%).TextString>%"))
                    (vla-put-TextString tgtVla fieldStr)
                    (vla-Update tgtVla)
                    (vla-EndUndoMark doc)
                    (vla-Regen doc acActiveViewport)
                    (princ "\n-> Linked successfully! Target now mirrors Source.")
                  )
                )
              )
            )
          )
        )
      )
    )
  )
  (princ "\nExited LINK1.")
  (princ)
)

;; =============================================================================
;; COMMAND 3: COPYLINK (Copy text/block & place a linked clone)
;; =============================================================================
(defun c:COPYLINK ( / acadObj doc ent obj srcId pt basePt destPt cloneObj atts fieldStr )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (setq ent (car (entsel "\nSelect text, MText, or block with attribute to copy-link: ")))
  (if (not ent)
    (princ "\nNothing selected.")
    (progn
      (setq obj (vlax-ename->vla-object ent))
      (setq basePt (getpoint "\nSpecify base point: "))
      (if basePt
        (progn
          (setq destPt (getpoint basePt "\nSpecify destination point on other section: "))
          (if destPt
            (progn
              (vla-StartUndoMark doc)
              ;; Copy object
              (setq cloneObj (vla-Copy obj))
              ;; Move to destination
              (vla-Move cloneObj (vlax-3d-point basePt) (vlax-3d-point destPt))

              ;; Wire up field
              (cond
                ;; If it's a block with attributes
                ((and (= (vla-get-ObjectName cloneObj) "AcDbBlockReference")
                      (= (vla-get-HasAttributes cloneObj) :vlax-true))
                 (setq srcAtt (car (vlax-invoke obj 'GetAttributes)))
                 (setq tgtAtt (car (vlax-invoke cloneObj 'GetAttributes)))
                 (if (and srcAtt tgtAtt)
                   (progn
                     (setq srcId (lt:get-obj-id-str srcAtt doc))
                     (setq fieldStr (strcat "%<\\AcObjProp Object(%<\\_ObjId " srcId ">%).TextString>%"))
                     (vla-put-TextString tgtAtt fieldStr)
                     (vla-Update tgtAtt)
                   )
                 )
                )
                ;; If it's Text or MText
                ((member (vla-get-ObjectName cloneObj) '("AcDbText" "AcDbMText"))
                 (setq srcId (lt:get-obj-id-str obj doc))
                 (setq fieldStr (strcat "%<\\AcObjProp Object(%<\\_ObjId " srcId ">%).TextString>%"))
                 (vla-put-TextString cloneObj fieldStr)
                 (vla-Update cloneObj)
                )
              )
              (vla-EndUndoMark doc)
              (vla-Regen doc acActiveViewport)
              (princ "\nCopied and dynamically linked!")
            )
          )
        )
      )
    )
  )
  (princ)
)

(princ "\n==================================================================")
(princ "\n LINK_TEXT Loaded! Available Commands:")
  (princ "\n   LINKBATCH : Auto-sort & batch-link two series (e.g. 1-11 horizontal to vertical)")
  (princ "\n   LINK1     : Click source, then click target to link one-by-one")
  (princ "\n   COPYLINK  : Duplicate an object and place it as a linked dynamic field")
(princ "\n==================================================================\n")
(princ)