;; HIDE_SHOW.LSP - Visibility Control for AutoCAD
;; --------------------------------------------------
;; Shortcut Keys:
;;   HH - Hide selected objects
;;   IL - Isolate selected objects
;;   HR - Restore hidden or isolated objects
;;
;; Description:
;; Provides commands to hide, isolate, and restore objects visibility using
;; AutoCAD's built-in object isolation features.

(defun c:HH ( / ss )
  ;; Command: HH
  ;; Purpose: Hide selected objects (equivalent to right-click > Isolate > Hide Objects)
  (setq ss (ssget))
  (if ss
    (progn
      (command "._hideobjects" ss "")
      (princ "\n✅ Selected objects are hidden.")
    )
    (princ "\n⚠ No objects selected.")
  )
  (princ)
)

(defun c:IL ( / ss )
  ;; Command: IL
  ;; Purpose: Isolate selected objects (hides everything else)
  (setq ss (ssget))
  (if ss
    (progn
      (command "._isolateobjects" ss "")
      (princ "\n✅ Selected objects isolated.")
    )
    (princ "\n⚠ No objects selected.")
  )
  (princ)
)

(defun c:HR ()
  ;; Command: HR
  ;; Purpose: Restore all hidden or isolated objects (equivalent to End Object Isolation)
  (command "._unisolateobjects")
  (princ "\n✅ All hidden or isolated objects restored.")
  (princ)
)

(princ "\n📦 HIDE_SHOW.LSP Loaded. Use HH, IL, or HR commands.")
(princ)
