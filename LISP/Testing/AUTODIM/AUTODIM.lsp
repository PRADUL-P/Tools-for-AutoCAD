;;; =========================================================================
;;; AUTODIM.lsp - Smart All-in-One Auto-Dimensioning Tool for AutoCAD
;;; =========================================================================
;;;
;;; DESCRIPTION:
;;;   A comprehensive, high-productivity auto-dimensioning suite supporting:
;;;
;;;   1. Segments & Geometry Mode [S]:
;;;      Automatically detects entity types and places appropriate dimensions:
;;;        - LINE           ➜ Aligned linear dimension
;;;        - LWPOLYLINE     ➜ Aligned dimension for straight edges,
;;;                           and Radius (R) dimension for curved/fillet edges
;;;        - CIRCLE         ➜ Diameter (⌀) dimension
;;;        - ARC            ➜ Radius (R) dimension
;;;
;;;   2. Bounding Box Mode [B]:
;;;      Instantly places overall Width & Height dimensions around any
;;;      selected objects (blocks, walls, rooms, mechanical parts).
;;;
;;;   3. Chain / Grid Mode [C]:
;;;      Generates continuous chain dimensions between lines/grids/centers
;;;      along the X or Y axis, plus an overall total dimension line!
;;;
;;; FEATURES:
;;;   - Supports selection BEFORE or AFTER entering command (Pre-selection / Pickfirst).
;;;   - Automatic smart offset calculation based on active DIMSCALE & DIMTXT.
;;;   - Preserves active DIMSTYLE and current layer.
;;;   - Works in Model Space, Paper Space Layouts, and inside BLOCK EDITOR.
;;;   - Single Undo Mark (Ctrl+Z reverses everything cleanly).
;;;
;;; COMMANDS:
;;;   AUTODIM  - Main command
;;;   ADIM     - Recommended fast shortcut
;;;   AD       - Quick 2-letter alias
;;;
;;; =========================================================================

(vl-load-com)

;;; -------------------------------------------------------------------------
;;; HELPER: Calculate smart default offset based on dimension text size
;;; -------------------------------------------------------------------------
(defun adim:default-offset ( / txtSz sc )
  (setq txtSz (getvar "DIMTXT"))
  (if (or (null txtSz) (<= txtSz 0.0)) (setq txtSz (getvar "TEXTSIZE")))
  (if (or (null txtSz) (<= txtSz 0.0)) (setq txtSz 2.5))
  (setq sc (getvar "DIMSCALE"))
  (if (or (null sc) (<= sc 0.0)) (setq sc 1.0))
  (* txtSz sc 3.5)
)

;;; -------------------------------------------------------------------------
;;; HELPER: Segment Key for Duplicate Filtering
;;; -------------------------------------------------------------------------
(defun adim:segment-key (p1 p2 / x1 y1 x2 y2)
  (setq x1 (rtos (car p1) 2 3)
        y1 (rtos (cadr p1) 2 3)
        x2 (rtos (car p2) 2 3)
        y2 (rtos (cadr p2) 2 3))
  (if (or (< (car p1) (car p2))
          (and (= (car p1) (car p2)) (< (cadr p1) (cadr p2))))
    (strcat x1 "," y1 "-" x2 "," y2)
    (strcat x2 "," y2 "-" x1 "," y1)
  )
)

;;; -------------------------------------------------------------------------
;;; HELPER: Extract polyline vertices AND bulges (for arc segments)
;;; -------------------------------------------------------------------------
(defun adim:get-polyline-data (ent / dxf data isClosed item curPt curBulge)
  (setq dxf (entget ent))
  (setq data '())
  (setq isClosed (= (logand (cdr (assoc 70 dxf)) 1) 1))

  (setq curPt nil curBulge 0.0)
  (foreach item dxf
    (cond
      ((= (car item) 10)
       (if curPt
         (setq data (cons (list curPt curBulge) data))
       )
       (setq curPt (cdr item)
             curBulge 0.0)
      )
      ((= (car item) 42)
       (setq curBulge (cdr item))
      )
    )
  )
  (if curPt
    (setq data (cons (list curPt curBulge) data))
  )
  (list (reverse data) isClosed)
)

;;; -------------------------------------------------------------------------
;;; HELPER: Calculate Radius, Center, and Arc Point from Polyline Bulge
;;; -------------------------------------------------------------------------
(defun adim:bulge-arc-info (p1 p2 b / d r midChord ang arcDir s ptOnArc center)
  (setq d (distance p1 p2))
  (if (or (< d 1e-4) (< (abs b) 1e-4))
    nil
    (progn
      ;; Radius = d * (1 + b^2) / (4 * |b|)
      (setq r (/ (* d (+ 1.0 (* b b))) (* 4.0 (abs b))))
      (setq midChord (list (/ (+ (car p1) (car p2)) 2.0)
                           (/ (+ (cadr p1) (cadr p2)) 2.0)
                           0.0))
      (setq ang (angle p1 p2))
      ;; Direction from chord to arc curve
      (setq arcDir (if (> b 0) (+ ang (/ pi 2.0)) (- ang (/ pi 2.0))))
      ;; Sagitta (height of arc from chord) = (d / 2) * |b|
      (setq s (* (/ d 2.0) (abs b)))
      (setq ptOnArc (polar midChord arcDir s))
      ;; Center is R distance from ptOnArc in opposite direction
      (setq center (polar ptOnArc (- arcDir pi) r))
      (list center r ptOnArc)
    )
  )
)

;;; -------------------------------------------------------------------------
;;; MODE 1: Geometry & Segment Auto-Dimensioning
;;; (Lines -> Aligned, Polyline Bulges/Arcs -> Radius, Circles -> Diameter)
;;; -------------------------------------------------------------------------
(defun adim:mode-segments (doc space ss / defOff userOff i ent entType dxf
                                          p1 p2 polyInfo pData isClosed j pt1 b1 pt2
                                          arcInfo center rad ptOnArc dimObj
                                          processedKeys segCount arcCount cirCount
                                          sa ea midAng chordPt)
  (setq defOff (adim:default-offset))
  (setq userOff (getdist (strcat "\nEnter linear segment offset distance <" (rtos defOff 2 1) ">: ")))
  (if (or (null userOff) (<= userOff 0.0)) (setq userOff defOff))

  (setq processedKeys '())
  (setq segCount 0 arcCount 0 cirCount 0)

  ;; Helper: Place straight line aligned dimension
  (defun adim:add-seg-dim (pt1 pt2 / key dist ang midPt perp dimPt dimObj)
    (setq dist (distance pt1 pt2))
    (if (> dist 1e-3)
      (progn
        (setq key (adim:segment-key pt1 pt2))
        (if (not (member key processedKeys))
          (progn
            (setq processedKeys (cons key processedKeys))
            (setq ang (angle pt1 pt2))
            (setq midPt (list (/ (+ (car pt1) (car pt2)) 2.0)
                              (/ (+ (cadr pt1) (cadr pt2)) 2.0)
                              0.0))
            (setq perp (+ ang (/ pi 2.0)))
            (setq dimPt (polar midPt perp userOff))

            (setq dimObj
              (vl-catch-all-apply
                'vla-AddDimAligned
                (list
                  space
                  (vlax-3d-point (list (car pt1) (cadr pt1) 0.0))
                  (vlax-3d-point (list (car pt2) (cadr pt2) 0.0))
                  (vlax-3d-point dimPt)
                )
              )
            )
            (if (not (vl-catch-all-error-p dimObj))
              (progn
                (vla-Update dimObj)
                (setq segCount (1+ segCount))
              )
            )
          )
        )
      )
    )
  )

  ;; Loop over selected objects
  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq dxf (entget ent))
    (setq entType (cdr (assoc 0 dxf)))

    (cond
      ;; -------------------------------------------------------------------
      ;; 1. LINE -> Aligned Dimension
      ;; -------------------------------------------------------------------
      ((= entType "LINE")
       (setq p1 (cdr (assoc 10 dxf)))
       (setq p2 (cdr (assoc 11 dxf)))
       (adim:add-seg-dim p1 p2)
      )

      ;; -------------------------------------------------------------------
      ;; 2. LWPOLYLINE -> Straight segments (Aligned) + Curved segments (Radius)
      ;; -------------------------------------------------------------------
      ((= entType "LWPOLYLINE")
       (setq polyInfo (adim:get-polyline-data ent))
       (setq pData (car polyInfo))
       (setq isClosed (cadr polyInfo))

       (if (>= (length pData) 2)
         (progn
           (setq j 0)
           (while (< j (1- (length pData)))
             (setq pt1 (car (nth j pData))
                   b1  (cadr (nth j pData))
                   pt2 (car (nth (1+ j) pData)))

             (if (< (abs b1) 1e-4)
               ;; Straight edge
               (adim:add-seg-dim pt1 pt2)
               ;; Curved edge (bulge) -> Radius Dimension
               (progn
                 (setq arcInfo (adim:bulge-arc-info pt1 pt2 b1))
                 (if arcInfo
                   (progn
                     (setq center  (nth 0 arcInfo)
                           rad     (nth 1 arcInfo)
                           ptOnArc (nth 2 arcInfo))
                     (setq dimObj
                       (vl-catch-all-apply
                         'vla-AddDimRadial
                         (list
                           space
                           (vlax-3d-point (list (car center) (cadr center) 0.0))
                           (vlax-3d-point (list (car ptOnArc) (cadr ptOnArc) 0.0))
                           0.0
                         )
                       )
                     )
                     (if (not (vl-catch-all-error-p dimObj))
                       (progn
                         (vla-Update dimObj)
                         (setq arcCount (1+ arcCount))
                       )
                     )
                   )
                 )
               )
             )
             (setq j (1+ j))
           )

           ;; If closed polyline, handle closing segment
           (if isClosed
             (progn
               (setq pt1 (car (last pData))
                     b1  (cadr (last pData))
                     pt2 (car (car pData)))
               (if (< (abs b1) 1e-4)
                 (adim:add-seg-dim pt1 pt2)
                 (progn
                   (setq arcInfo (adim:bulge-arc-info pt1 pt2 b1))
                   (if arcInfo
                     (progn
                       (setq center  (nth 0 arcInfo)
                             rad     (nth 1 arcInfo)
                             ptOnArc (nth 2 arcInfo))
                       (setq dimObj
                         (vl-catch-all-apply
                           'vla-AddDimRadial
                           (list
                             space
                             (vlax-3d-point (list (car center) (cadr center) 0.0))
                             (vlax-3d-point (list (car ptOnArc) (cadr ptOnArc) 0.0))
                             0.0
                           )
                         )
                       )
                       (if (not (vl-catch-all-error-p dimObj))
                         (progn
                           (vla-Update dimObj)
                           (setq arcCount (1+ arcCount))
                         )
                       )
                     )
                   )
                 )
               )
             )
           )
         )
       )
      )

      ;; -------------------------------------------------------------------
      ;; 3. CIRCLE -> Diameter Dimension (⌀)
      ;; -------------------------------------------------------------------
      ((= entType "CIRCLE")
       (setq center (cdr (assoc 10 dxf)))
       (setq rad (cdr (assoc 40 dxf)))
       (if (> rad 1e-4)
         (progn
           (setq pt1 (polar center (/ pi 4.0) rad))
           (setq pt2 (polar center (+ (/ pi 4.0) pi) rad))
           (setq dimObj
             (vl-catch-all-apply
               'vla-AddDimDiametric
               (list
                 space
                 (vlax-3d-point (list (car pt1) (cadr pt1) 0.0))
                 (vlax-3d-point (list (car pt2) (cadr pt2) 0.0))
                 0.0
               )
             )
           )
           (if (not (vl-catch-all-error-p dimObj))
             (progn
               (vla-Update dimObj)
               (setq cirCount (1+ cirCount))
             )
           )
         )
       )
      )

      ;; -------------------------------------------------------------------
      ;; 4. ARC -> Radius Dimension (R)
      ;; -------------------------------------------------------------------
      ((= entType "ARC")
       (setq center (cdr (assoc 10 dxf)))
       (setq rad (cdr (assoc 40 dxf)))
       (setq sa (cdr (assoc 50 dxf)))
       (setq ea (cdr (assoc 51 dxf)))
       (if (> rad 1e-4)
         (progn
           (if (< ea sa) (setq ea (+ ea (* 2.0 pi))))
           (setq midAng (/ (+ sa ea) 2.0))
           (setq chordPt (polar center midAng rad))
           (setq dimObj
             (vl-catch-all-apply
               'vla-AddDimRadial
               (list
                 space
                 (vlax-3d-point (list (car center) (cadr center) 0.0))
                 (vlax-3d-point (list (car chordPt) (cadr chordPt) 0.0))
                 0.0
               )
             )
           )
           (if (not (vl-catch-all-error-p dimObj))
             (progn
               (vla-Update dimObj)
               (setq arcCount (1+ arcCount))
             )
           )
         )
       )
      )
    )
    (setq i (1+ i))
  )

  (princ (strcat "\n✅ Dimensions Created:"
                 "\n   • Linear Segments: " (itoa segCount)
                 "\n   • Arc / Fillet Radii (R): " (itoa arcCount)
                 "\n   • Circle Diameters (⌀): " (itoa cirCount)))
)

;;; -------------------------------------------------------------------------
;;; MODE 2: Bounding Box Auto-Dimensioning
;;; -------------------------------------------------------------------------
(defun adim:mode-box (doc space ss / minX minY maxX maxY i ent entObj
                                     minPt maxPt minL maxL defOff userPt
                                     dimLineX dimLineY dimH dimV count)
  (setq minX 1e99 minY 1e99 maxX -1e99 maxY -1e99)
  (setq count 0)

  ;; Compute overall bounding box
  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq entObj (vlax-ename->vla-object ent))
    (if (not (vl-catch-all-error-p
               (vl-catch-all-apply 'vla-GetBoundingBox (list entObj 'minPt 'maxPt))))
      (progn
        (setq minL (vlax-safearray->list minPt))
        (setq maxL (vlax-safearray->list maxPt))
        (if (< (car minL) minX) (setq minX (car minL)))
        (if (< (cadr minL) minY) (setq minY (cadr minL)))
        (if (> (car maxL) maxX) (setq maxX (car maxL)))
        (if (> (cadr maxL) maxY) (setq maxY (cadr maxL)))
        (setq count (1+ count))
      )
    )
    (setq i (1+ i))
  )

  (if (= count 0)
    (princ "\n⚠️ Unable to calculate bounding box for selected entities.")
    (progn
      (setq defOff (adim:default-offset))
      (setvar "DIMZIN" 8)

      (princ (strcat "\n📐 Bounding Box: Width = " (rtos (- maxX minX) 2 2)
                     " | Height = " (rtos (- maxY minY) 2 2)))
      (setq userPt (getpoint (strcat "\nPick dimension placement point <default offset " 
                                     (rtos defOff 2 1) ">: ")))

      (if userPt
        (progn
          (setq dimLineY (cadr userPt))
          (setq dimLineX (car userPt))
        )
        (progn
          (setq dimLineY (- minY defOff))
          (setq dimLineX (- minX defOff))
        )
      )

      ;; Horizontal Dimension (Width)
      (setq dimH
        (vla-AddDimRotated
          space
          (vlax-3d-point (list minX minY 0.0))
          (vlax-3d-point (list maxX minY 0.0))
          (vlax-3d-point (list (/ (+ minX maxX) 2.0) dimLineY 0.0))
          0.0
        )
      )

      ;; Vertical Dimension (Height)
      (setq dimV
        (vla-AddDimRotated
          space
          (vlax-3d-point (list minX minY 0.0))
          (vlax-3d-point (list minX maxY 0.0))
          (vlax-3d-point (list dimLineX (/ (+ minY maxY) 2.0) 0.0))
          (/ pi 2.0)
        )
      )

      (vla-Update dimH)
      (vla-Update dimV)
      (princ "\n✅ Bounding box dimensions created (Width & Height).")
    )
  )
)

;;; -------------------------------------------------------------------------
;;; MODE 3: Chain / Grid Dimensioning
;;; -------------------------------------------------------------------------
(defun adim:mode-chain (doc space ss / defOff dir opt i ent dxf entType
                                       p1 p2 coords xList yList pickPt
                                       dimLine basePos count overallObj dimObj
                                       polyInfo pData pt)
  (initget "Horizontal Vertical Auto")
  (setq dir (getkword "\nChain direction [Horizontal/Vertical/Auto] <Auto>: "))
  (if (or (null dir) (= dir "Auto"))
    (setq dir "Auto")
  )

  ;; Collect coordinate points from lines, polylines, circles, arcs
  (setq coords '())
  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq dxf (entget ent))
    (setq entType (cdr (assoc 0 dxf)))

    (cond
      ((= entType "LINE")
       (setq coords (cons (cdr (assoc 10 dxf)) coords))
       (setq coords (cons (cdr (assoc 11 dxf)) coords))
      )
      ((= entType "LWPOLYLINE")
       (setq polyInfo (adim:get-polyline-data ent))
       (foreach ptItem (car polyInfo)
         (setq coords (cons (car ptItem) coords))
       )
      )
      ((or (= entType "CIRCLE") (= entType "ARC"))
       (setq coords (cons (cdr (assoc 10 dxf)) coords)) ; Center point
      )
      (t
       (setq entObj (vlax-ename->vla-object ent))
       (if (not (vl-catch-all-error-p
                  (vl-catch-all-apply 'vla-GetBoundingBox (list entObj 'minPt 'maxPt))))
         (progn
           (setq coords (cons (vlax-safearray->list minPt) coords))
           (setq coords (cons (vlax-safearray->list maxPt) coords))
         )
       )
      )
    )
    (setq i (1+ i))
  )

  (if (< (length coords) 2)
    (princ "\n⚠️ Not enough points found for chain dimensioning.")
    (progn
      (setq defOff (adim:default-offset))

      ;; Auto direction detection: check bounding spread
      (if (= dir "Auto")
        (progn
          (setq xVals (mapcar 'car coords))
          (setq yVals (mapcar 'cadr coords))
          (setq xSpread (- (apply 'max xVals) (apply 'min xVals)))
          (setq ySpread (- (apply 'max yVals) (apply 'min yVals)))
          (if (>= xSpread ySpread)
            (setq dir "Horizontal")
            (setq dir "Vertical")
          )
          (princ (strcat "\nAuto-detected direction: " dir))
        )
      )

      ;; Horizontal Chain (X axis)
      (if (= dir "Horizontal")
        (progn
          (setq rawX (vl-sort (mapcar 'car coords) '<))
          (setq cleanX (list (car rawX)))
          (foreach x (cdr rawX)
            (if (> (- x (car cleanX)) 0.01)
              (setq cleanX (cons x cleanX))
            )
          )
          (setq cleanX (reverse cleanX))

          (if (< (length cleanX) 2)
            (princ "\n⚠️ Insufficient distinct X coordinates for horizontal chain.")
            (progn
              (setq pickPt (getpoint "\nPick placement line for chain dimensions: "))
              (if (null pickPt)
                (setq basePos (apply 'min (mapcar 'cadr coords))
                      dimLine (- basePos defOff))
                (setq dimLine (cadr pickPt))
              )

              (setq count 0)
              (setq i 0)
              (while (< i (1- (length cleanX)))
                (setq x1 (nth i cleanX)
                      x2 (nth (1+ i) cleanX))
                (setq dimObj
                  (vla-AddDimRotated
                    space
                    (vlax-3d-point (list x1 dimLine 0.0))
                    (vlax-3d-point (list x2 dimLine 0.0))
                    (vlax-3d-point (list (/ (+ x1 x2) 2.0) dimLine 0.0))
                    0.0
                  )
                )
                (vla-Update dimObj)
                (setq count (1+ count))
                (setq i (1+ i))
              )

              ;; Overall dimension
              (setq overallObj
                (vla-AddDimRotated
                  space
                  (vlax-3d-point (list (car cleanX) dimLine 0.0))
                  (vlax-3d-point (list (last cleanX) dimLine 0.0))
                  (vlax-3d-point (list (/ (+ (car cleanX) (last cleanX)) 2.0)
                                       (+ dimLine (if (null pickPt) (- defOff) defOff))
                                       0.0))
                  0.0
                )
              )
              (vla-Update overallObj)
              (princ (strcat "\n✅ Created " (itoa count) " chain dimension(s) + 1 overall total dimension."))
            )
          )
        )

        ;; Vertical Chain (Y axis)
        (progn
          (setq rawY (vl-sort (mapcar 'cadr coords) '<))
          (setq cleanY (list (car rawY)))
          (foreach y (cdr rawY)
            (if (> (- y (car cleanY)) 0.01)
              (setq cleanY (cons y cleanY))
            )
          )
          (setq cleanY (reverse cleanY))

          (if (< (length cleanY) 2)
            (princ "\n⚠️ Insufficient distinct Y coordinates for vertical chain.")
            (progn
              (setq pickPt (getpoint "\nPick placement line for vertical chain dimensions: "))
              (if (null pickPt)
                (setq basePos (apply 'min (mapcar 'car coords))
                      dimLine (- basePos defOff))
                (setq dimLine (car pickPt))
              )

              (setq count 0)
              (setq i 0)
              (while (< i (1- (length cleanY)))
                (setq y1 (nth i cleanY)
                      y2 (nth (1+ i) cleanY))
                (setq dimObj
                  (vla-AddDimRotated
                    space
                    (vlax-3d-point (list dimLine y1 0.0))
                    (vlax-3d-point (list dimLine y2 0.0))
                    (vlax-3d-point (list dimLine (/ (+ y1 y2) 2.0) 0.0))
                    (/ pi 2.0)
                  )
                )
                (vla-Update dimObj)
                (setq count (1+ count))
                (setq i (1+ i))
              )

              ;; Overall dimension
              (setq overallObj
                (vla-AddDimRotated
                  space
                  (vlax-3d-point (list dimLine (car cleanY) 0.0))
                  (vlax-3d-point (list dimLine (last cleanY) 0.0))
                  (vlax-3d-point (list (+ dimLine (if (null pickPt) (- defOff) defOff))
                                       (/ (+ (car cleanY) (last cleanY)) 2.0)
                                       0.0))
                  (/ pi 2.0)
                )
              )
              (vla-Update overallObj)
              (princ (strcat "\n✅ Created " (itoa count) " chain dimension(s) + 1 overall total dimension."))
            )
          )
        )
      )
    )
  )
)

;;; -------------------------------------------------------------------------
;;; MAIN DISPATCHER: adim:main
;;; -------------------------------------------------------------------------
(defun adim:main ( / acadObj doc space oldEcho oldErr pickFirst ss mode )
  (setq acadObj (vlax-get-acad-object))
  (setq doc     (vla-get-ActiveDocument acadObj))
  (setq space   (vla-get-Block (vla-get-ActiveLayout doc)))
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
      (princ (strcat "\n⚠️ AUTODIM Error: " msg))
    )
    (princ)
  )

  ;; -------------------------------------------------------------------------
  ;; 1. Check for Pre-Selection (Pickfirst)
  ;; -------------------------------------------------------------------------
  (setq pickFirst (ssget "_I"))
  (if (and pickFirst (> (sslength pickFirst) 0))
    (progn
      (setq ss pickFirst)
      (sssetfirst nil nil) ; Clear active selection grips
    )
    ;; -----------------------------------------------------------------------
    ;; 2. Prompt for Selection
    ;; -----------------------------------------------------------------------
    (progn
      (princ "\nSelect object(s) to auto-dimension [Window/Crossing/ALL/Pick]: ")
      (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE,CIRCLE,ARC,INSERT,ELLIPSE,SPLINE,SOLID,3DFACE"))))
    )
  )

  (if (or (null ss) (= (sslength ss) 0))
    (progn
      (princ "\n⚠️ No supported objects selected.")
      (if oldEcho (setvar "CMDECHO" oldEcho))
      (setq *error* oldErr)
      (exit)
    )
  )

  ;; -------------------------------------------------------------------------
  ;; 3. Choose Auto-Dimensioning Mode
  ;; -------------------------------------------------------------------------
  (initget "Segments Box Chain")
  (setq mode (getkword "\nChoose Dimension Mode [Segments (Lines/Curves/Circles)/Box (Overall)/Chain (Continuous)] <Segments>: "))
  (if (null mode) (setq mode "Segments"))

  ;; Start Undo Mark
  (vla-StartUndoMark doc)

  (cond
    ((= mode "Segments")
     (adim:mode-segments doc space ss)
    )
    ((= mode "Box")
     (adim:mode-box doc space ss)
    )
    ((= mode "Chain")
     (adim:mode-chain doc space ss)
    )
  )

  (vla-EndUndoMark doc)
  (if oldEcho (setvar "CMDECHO" oldEcho))
  (setq *error* oldErr)
  (princ "\n🏁 AUTODIM completed.")
  (princ)
)

;;; -------------------------------------------------------------------------
;;; COMMAND DEFINITIONS
;;; -------------------------------------------------------------------------
(defun c:AUTODIM ()
  (adim:main)
)

(defun c:ADIM ()
  (adim:main)
)

(defun c:AD ()
  (adim:main)
)

;;; -------------------------------------------------------------------------
;;; Load Notification
;;; -------------------------------------------------------------------------
(princ "\n📦 AUTODIM.lsp loaded successfully!")
(princ "\n   Type 'ADIM' or 'AD' to start auto-dimensioning.")
(princ "\n   Automatically handles Lines (Linear), Arcs/Fillets (Radius R), Circles (Diameter ⌀), and Overall Box!")
(princ)
