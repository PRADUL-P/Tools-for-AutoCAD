;; =============================================================================
;; TCOUNT_PLUS.LSP – Advanced Directional Text & Attribute Renumbering Tool
;; =============================================================================
;; Description:
;;   An enhanced, flexible replacement for AutoCAD's native Express Tool TCOUNT.
;;
;; Key Improvements over Native TCOUNT:
;;   1. Multi-Directional Sorting:
;;      - [LR] Left to Right
;;      - [RL] Right to Left
;;      - [TB] Top to Bottom
;;      - [BT] Bottom to Top
;;      - [SEL] Exact Selection Order
;;   2. Simultaneous Custom Prefix & Suffix (e.g. "SEC-" + 1 + "-A" -> "SEC-1-A")
;;   3. Padding / Leading Zeros: None, 01, 001, 0001
;;   4. Flexible Modes: Overwrite, Prefix, or Suffix
;;   5. Full Entity Support: TEXT, MTEXT, ATTRIB, and Blocks with attributes
;;   6. Single Undo Mark (one Ctrl+Z to undo all)
;;
;; Commands:
;;   TC          : Fast shortcut
;;   TCOUNTPLUS  : Full command name
;; =============================================================================

(vl-load-com)

;; Helper: Extract specific attribute from block
(defun tc:get-att-from-blk (blkObj tagFilter / atts found)
  (if (and (= (vla-get-ObjectName blkObj) "AcDbBlockReference")
           (= (vla-get-HasAttributes blkObj) :vlax-true))
    (progn
      (setq atts (vlax-invoke blkObj 'GetAttributes))
      (cond
        ((and tagFilter (/= tagFilter ""))
         (foreach a atts
           (if (= (strcase (vla-get-TagString a)) (strcase tagFilter))
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

;; Helper: Format number with leading zeros
(defun tc:format-number (n padOpt / s)
  (setq s (itoa n))
  (cond
    ((= padOpt "2-digits")
     (while (< (strlen s) 2) (setq s (strcat "0" s)))
    )
    ((= padOpt "3-digits")
     (while (< (strlen s) 3) (setq s (strcat "0" s)))
    )
    ((= padOpt "4-digits")
     (while (< (strlen s) 4) (setq s (strcat "0" s)))
    )
  )
  s
)

;; Helper: Get target text entity and its coordinates
(defun tc:get-entity-info (ent tagFilter / data typ vla-obj pt att)
  (setq data (entget ent))
  (setq typ  (cdr (assoc 0 data)))
  (setq vla-obj (vlax-ename->vla-object ent))
  (cond
    ((member typ '("TEXT" "MTEXT" "ATTRIB"))
     (setq pt (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj))))
     (list pt vla-obj)
    )
    ((= typ "INSERT")
     (setq att (tc:get-att-from-blk vla-obj tagFilter))
     (if att
       (progn
         (setq pt (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint vla-obj))))
         (list pt att)
       )
       nil
     )
    )
    (t nil)
  )
)

;; =============================================================================
;; MAIN FUNCTION: TCOUNT_PLUS
;; =============================================================================
(defun c:TC () (c:TCOUNTPLUS))

(defun c:TCOUNTPLUS ( / acadObj doc ss count i ent pair itemList
                        sampleBlk atts detectedTags tagFilter tagPrompt
                        dirOpt modeOpt startNum incNum padOpt pfx sfx
                        curNum numStr oldTxt newTxt tgtObj )

  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))

  (princ "\n=======================================================")
  (princ "\n TCOUNT_PLUS: Advanced Directional Text Renumbering")
  (princ "\n=======================================================")

  ;; 1. Select Objects
  (princ "\nSelect TEXT, MTEXT, or Attributed Blocks to renumber: ")
  (setq ss (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (0 . "INSERT") (0 . "ATTRIB") (-4 . "OR>"))))

  (if (not ss)
    (princ "\nNo valid text objects selected. Exiting.")
    (progn
      ;; Check for multi-attribute blocks
      (setq sampleBlk nil tagFilter nil i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
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
              (princ (strcat "\nDetected Block Tags: [" (apply 'strcat (mapcar '(lambda (x) (strcat x " ")) detectedTags)) "]"))
              (setq tagPrompt (strcase (getstring "\nEnter Attribute Tag to renumber (or Enter to auto-detect number attribute): ")))
              (if (/= tagPrompt "") (setq tagFilter tagPrompt))
            )
          )
        )
      )

      ;; Build items list: (( (x y z) vla-obj ) ...)
      (setq itemList '() i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq pair (tc:get-entity-info ent tagFilter))
        (if pair (setq itemList (cons pair itemList)))
        (setq i (1+ i))
      )

      ;; Reverse so initial list matches selection order
      (setq itemList (reverse itemList))

      ;; 2. Direction Prompt
      (initget "LR RL TB BT SEL")
      (setq dirOpt (getkword "\nSort Direction [Left-to-right (LR) / Right-to-left (RL) / Top-to-bottom (TB) / Bottom-to-top (BT) / Selection-order (SEL)] <LR>: "))
      (if (or (null dirOpt) (= dirOpt "")) (setq dirOpt "LR"))

      ;; Sort items based on chosen direction
      (cond
        ((= dirOpt "LR")
         (setq itemList (vl-sort itemList '(lambda (a b) (< (caar a) (caar b)))))
        )
        ((= dirOpt "RL")
         (setq itemList (vl-sort itemList '(lambda (a b) (> (caar a) (caar b)))))
        )
        ((= dirOpt "TB")
         (setq itemList (vl-sort itemList '(lambda (a b) (> (cadar a) (cadar b)))))
        )
        ((= dirOpt "BT")
         (setq itemList (vl-sort itemList '(lambda (a b) (< (cadar a) (cadar b)))))
        )
        ((= dirOpt "SEL")
         ;; Keep selection order unchanged
        )
      )

      ;; 3. Placement Mode
      (initget "Overwrite Prefix Suffix")
      (setq modeOpt (getkword "\nPlacement Mode [Overwrite / Prefix / Suffix] <Overwrite>: "))
      (if (or (null modeOpt) (= modeOpt "")) (setq modeOpt "Overwrite"))

      ;; 4. Start Number & Increment
      (setq startNum (getint "\nEnter starting number <1>: "))
      (if (null startNum) (setq startNum 1))

      (setq incNum (getint "\nEnter increment <1>: "))
      (if (null incNum) (setq incNum 1))

      ;; 5. Leading Zeros / Padding
      (initget "None 2-digits 3-digits 4-digits")
      (setq padOpt (getkword "\nLeading Zeros [None (1,2..) / 2-digits (01,02..) / 3-digits (001..) / 4-digits] <None>: "))
      (if (or (null padOpt) (= padOpt "")) (setq padOpt "None"))

      ;; 6. Prefix and Suffix
      (setq pfx (getstring t "\nEnter Prefix (press Enter for none): "))
      (setq sfx (getstring t "\nEnter Suffix (press Enter for none): "))

      ;; 7. Execute Renumbering in Single Undo Mark
      (vla-StartUndoMark doc)

      (setq curNum startNum count 0)
      (foreach item itemList
        (setq tgtObj (cadr item))
        (setq numStr (tc:format-number curNum padOpt))
        (setq oldTxt (vla-get-TextString tgtObj))

        ;; Compute new text string
        (setq newTxt
          (cond
            ((= modeOpt "Overwrite")
             (strcat pfx numStr sfx)
            )
            ((= modeOpt "Prefix")
             (strcat pfx numStr sfx oldTxt)
            )
            ((= modeOpt "Suffix")
             (strcat oldTxt pfx numStr sfx)
            )
          )
        )

        ;; Apply new text
        (vl-catch-all-apply 'vla-put-TextString (list tgtObj newTxt))
        (vl-catch-all-apply 'vla-Update (list tgtObj))

        (setq curNum (+ curNum incNum))
        (setq count  (1+ count))
      )

      (vla-EndUndoMark doc)
      (vla-Regen doc acActiveViewport)

      (princ (strcat "\n\nSUCCESS: Renumbered " (itoa count) " text/attribute object(s) in "
                     (cond
                       ((= dirOpt "LR") "Left-to-Right")
                       ((= dirOpt "RL") "Right-to-Left")
                       ((= dirOpt "TB") "Top-to-Bottom")
                       ((= dirOpt "BT") "Bottom-to-Top")
                       (t "Selection Order")
                     )
                     " direction!"))
    )
  )
  (princ)
)

(princ "\n==================================================================")
(princ "\n TCOUNT_PLUS Loaded!")
(princ "\n Commands: TC or TCOUNTPLUS")
(princ "\n Renumber texts in ANY direction (LR, RL, TB, BT, SEL) with Prefix & Suffix.")
(princ "\n==================================================================\n")
(princ)