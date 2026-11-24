# 📐 AUTODIM – Smart All-in-One Auto-Dimensioning Tool

A versatile and high-productivity auto-dimensioning suite for AutoCAD. Stop clicking four points for every single dimension—automatically dimension entire boundaries, polylines, segments, and structural grids in seconds!

---

## ⚡ 3 Powerful Dimensioning Modes

### 1. 📦 Bounding Box Mode (`Box` / `B`) — Fastest
* Window-select any object or group of objects (blocks, furniture, room walls, equipment, mechanical parts).
* Instantly places **Overall Width** and **Overall Height** dimensions outside the object boundary.
* You can click a custom placement point, or press **Enter** to place automatically at the bottom and left with smart text-height offsets.

### 2. 📏 Segment Mode (`Segments` / `S`)
* Window-select lines and polylines.
* Automatically creates an aligned dimension along **every individual straight line or polyline edge**.
* Automatically calculates perpendicular offsets to avoid overlapping the line work.
* Filters out duplicate/overlapping segment lines.

### 3. ⛓️ Chain / Continuous Mode (`Chain` / `C`)
* Select lines, grid lines, or objects across an axis.
* Automatically extracts and sorts coordinates along the horizontal (X) or vertical (Y) direction.
* Creates clean, continuous **chain dimensions between each pair**, plus an **overall total dimension line**!

---

## 🚀 Commands

| Command | Shortcut | Description |
|---|---|---|
| `ADIM` | **`AUTODIM`**, **`AD`** | Launch the multi-mode auto-dimensioning tool. |

---

## 🎯 How to Use

### Method 1: Pre-Selection (Select First)
1. Window-select your objects on screen.
2. Type **`ADIM`** (or `AD`) and press **Enter**.
3. Choose your mode:
   * Press **Enter** for `[Box]` (Overall Width & Height).
   * Type **`S`** for `[Segments]` (Dimension every edge).
   * Type **`C`** for `[Chain]` (Continuous grid/chain dimensions).
4. Done!

### Method 2: Post-Selection (Run First)
1. Type **`ADIM`** (or `AD`) and press **Enter**.
2. Select your objects on screen (window, crossing, or pick) and press **Enter**.
3. Choose your mode: `Box`, `Segments`, or `Chain`.
4. Done!

---

## 🛡️ Smart CAD Features
* **Smart Offsets**: Automatically calculates offset distances based on your active `DIMSCALE` and `DIMTXT` so text never overlaps geometry.
* **Respects Drawing Standards**: Uses your active `DIMSTYLE` and current active Layer.
* **Space Compatibility**: Works seamlessly in Model Space, Paper Space Layouts, and inside the **Block Editor (`BEDIT`)**.
* **Clean Single Undo**: All created dimensions are bundled in one undo mark (`Ctrl+Z` reverses the operation in one click).

---

## 💻 Load in AutoCAD
```lisp
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/AUTODIM/AUTODIM.lsp")
```
*(Or load via `APPLOAD` and add to your Startup Suite).*
