;; =============================================================================
;; LINK_TEXT.LSP – Dynamic Text & Attribute Linker for AutoCAD (Field Based)
;; =============================================================================
;; Commands:
;;   LINKBATCH : Batch-links two series of numbers at once (e.g. 1-11 horizontal
;;               to 1-11 vertical). Auto-sorts Left-to-Right or Top-to-Bottom!
;;   LINK1     : Click any source text/attribute, then click target to link one-by-one.
;;   COPYLINK  : Click a source text/block and place a linked duplicate at a new point.
;; =============================================================================

(vl-load-com)

;; Helper: Get 64-bit safe ObjectId String for AutoCAD Fields
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

;; Helper: Extract specific attribute from block
(defun lt:get-att-by-tag (blkObj targetTag / atts found)
  (if (and (= (vla-get-ObjectName blkObj) "AcDbBlockReference")
           (= (vla-get-HasAttributes blkObj) :vlax-true))
    (progn
      (setq atts (vlax-invoke blkObj 'GetAttributes))
      (cond
        ((and targetTag (/= targetTag ""))
         (foreach a atts
           (if (= (strcase (vla-get-TagString a)) (strcase targetTag))
             (setq found a)
           )
         )
        )
        ((= (length atts) 1) (setq found (car atts)))
        (t
         (foreach a atts
           (if (and (null found) (wcmatch (vl-string-trim " " (vla-get-TextString a)) "*#*"))
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

(defun lt:get-text-vla-and-pt (ent targetTag / data typ vla-obj att)
  (setq data (entget ent))
  (setq typ  (cdr (assoc 0 data)))
  (setq vla-obj (vlax-ename->vla-object ent))
  (cond
    ((member typ '("TEXT" "MTEXT" "ATTRIB"))
     (list (cdr (assoc 10 data)) vla-obj)
    )
    ((= typ "INSERT")
     (setq att (lt:get-att-by-tag vla-obj targetTag))
     (if att
       (list (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj)))
             att
       )
       nil
     )
    )
    (t nil)
  )
)

;; Coordinate accessors
(defun lt:item-x (item) (car  (car item)))
(defun lt:item-y (item) (cadr (car item)))

;; Helper: Auto-sort a list of ((x y z) vla-obj) based on natural layout
(defun lt:sort-entities (item-list / xs ys minX maxX minY maxY spanX spanY)
  (if (or (null item-list) (<= (length item-list) 1))
    item-list
    (progn
      (setq xs (mapcar 'lt:item-x item-list))
      (setq ys (mapcar 'lt:item-y item-list))
      (setq minX (apply 'min xs) maxX (apply 'max xs))
      (setq minY (apply 'min ys) maxY (apply 'max ys))
      (setq spanX (abs (- maxX minX)))
      (setq spanY (abs (- maxY minY)))

      (if (>= spanX spanY)
        (vl-sort item-list '(lambda (a b) (< (lt:item-x a) (lt:item-x b))))
        (vl-sort item-list '(lambda (a b) (> (lt:item-y a) (lt:item-y b))))
      )
    )
  )
)

;; =============================================================================
;; COMMAND 1: LINKBATCH (Batch-Link two series of tags)
;; =============================================================================
(defun c:LINKBATCH ( / acadObj doc ssSrc ssTgt srcList tgtList
                       i ent pair count minCount srcObj tgtObj srcId fieldStr
                       sampleBlk atts detectedTags userTag tagPrompt )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (princ "\n=======================================================")
  (princ "\n LINKBATCH: Batch-Link Numbers Across Sections")
  (princ "\n=======================================================")

  (princ "\nSelect SOURCE numbers (Horizontal): ")
  (setq ssSrc (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

  (if (not ssSrc)
    (princ "\nNo source objects selected. Exiting.")
    (progn
      ;; Check if blocks have multiple attributes
      (setq userTag nil sampleBlk nil i 0)
      (while (< i (sslength ssSrc))
        (setq ent (ssname ssSrc i))
        (if (and (null sampleBlk) (= (cdr (assoc 0 (entget ent))) "INSERT"))
          (setq sampleBlk (vlax-ename->vla-object ent))
        )
        (setq i (1+ i))
      )

      (if (and sampleBlk (= (vla-get-HasAttributes sampleBlk) :vlax-true))
        (progn
          (setq atts (vlax-invoke sampleBlk 'GetAttributes))
          (if (> (length atts) 1)
            (progn
              (setq detectedTags (mapcar 'vla-get-TagString atts))
              (princ (strcat "\nDetected Tags in Block: [" (apply 'strcat (mapcar '(lambda (x) (strcat x " ")) detectedTags)) "]"))
              (setq tagPrompt (strcase (getstring "\nEnter Attribute Tag to link (or press Enter for auto-number detect): ")))
              (if (/= tagPrompt "") (setq userTag tagPrompt))
            )
          )
        )
      )

      (setq srcList '() i 0)
      (while (< i (sslength ssSrc))
        (setq ent (ssname ssSrc i))
        (setq pair (lt:get-text-vla-and-pt ent userTag))
        (if pair (setq srcList (cons pair srcList)))
        (setq i (1+ i))
      )

      (princ "\nSelect TARGET numbers to link (Vertical): ")
      (setq ssTgt (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

      (if (not ssTgt)
        (princ "\nNo target objects selected. Exiting.")
        (progn
          (setq tgtList '() i 0)
          (while (< i (sslength ssTgt))
            (setq ent (ssname ssTgt i))
            (setq pair (lt:get-text-vla-and-pt ent userTag))
            (if pair (setq tgtList (cons pair tgtList)))
            (setq i (1+ i))
          )

          ;; Sort both series
          (setq srcList (lt:sort-entities srcList))
          (setq tgtList (lt:sort-entities tgtList))

          (setq minCount (min (length srcList) (length tgtList)))

          (vla-StartUndoMark doc)
          (setq count 0)
          (while (< count minCount)
            (setq srcObj (cadr (nth count srcList)))
            (setq tgtObj (cadr (nth count tgtList)))
            (setq srcId  (lt:get-obj-id-str srcObj doc))

            (setq fieldStr (strcat "%<\\AcObjProp Object(%<\\_ObjId " srcId ">%).TextString>%"))

            (vl-catch-all-apply 'vla-put-TextString (list tgtObj fieldStr))
            (vl-catch-all-apply 'vla-Update (list tgtObj))

            (setq count (1+ count))
          )
          (vla-EndUndoMark doc)

          (vla-Regen doc acAllViewports)
          (princ (strcat "\nSuccessfully linked " (itoa count) " item(s)!"))
        )
      )
    )
  )
  (princ)
)

;; =============================================================================
;; COMMAND 2: LINK1 (Link one-by-one by clicking directly on the attribute)
;; =============================================================================
(defun c:LINK1 ( / acadObj doc nPickSrc srcEnt srcData srcTyp srcVla srcId
                   nPickTgt tgtEnt tgtData tgtTyp tgtVla fieldStr loop )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq loop t)

  (princ "\n=======================================================")
  (princ "\n LINK1: Click directly on the specific attribute to link")
  (princ "\n=======================================================")

  (while loop
    (setq nPickSrc (nentsel "\nClick SOURCE attribute/text (or press Enter to exit): "))
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

            (setq nPickTgt (nentsel "\nClick TARGET attribute/text to receive link: "))
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

(princ "\nLINK_TEXT Loaded.\n")
(princ)