# 📐 AUTODIM – Smart Multi-Geometry Auto-Dimensioning Tool

A versatile and high-productivity auto-dimensioning suite for AutoCAD that **automatically detects entity types and geometry**:
* **Lines** $\rightarrow$ Aligned Linear Dimensions
* **Curved Polyline Edges (Fillets / Bulges)** $\rightarrow$ Radius Dimensions (`R`)
* **Arcs** $\rightarrow$ Radius Dimensions (`R`)
* **Circles** $\rightarrow$ Diameter Dimensions (`⌀`)
* **Overall Boundaries** $\rightarrow$ Width & Height Dimensions
* **Grids & Series** $\rightarrow$ Continuous Chain Dimensions

---

## ⚡ 3 Powerful Dimensioning Modes

### 1. 📏 Segments & Geometry Mode (`Segments` / `S`) — *Default*
Window-select your drawing geometry and `AUTODIM` automatically detects each object type:
* **`LINE`**: Creates an aligned linear dimension offset perpendicularly.
* **`LWPOLYLINE`**:
  * Straight edges $\rightarrow$ Aligned linear dimension.
  * Curved / filleted edges (bulges) $\rightarrow$ Native **Radius (`R`) dimension**.
* **`ARC`**: Automatically creates a native **Radius (`R`) dimension**.
* **`CIRCLE`**: Automatically creates a native **Diameter (`⌀`) dimension**.
* Filters duplicate/overlapping segments automatically!

### 2. 📦 Bounding Box Mode (`Box` / `B`)
* Window-select any object or group of objects (blocks, furniture, room walls, equipment, mechanical parts).
* Instantly places **Overall Width** and **Overall Height** dimensions outside the object boundary.
* You can click a custom placement point, or press **Enter** to place automatically at the bottom and left with smart text-height offsets.

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
1. Window-select your lines, circles, arcs, and polylines on screen.
2. Type **`ADIM`** (or `AD`) and press **Enter**.
3. Press **Enter** for `[Segments]` (default):
   * All lines get linear dimensions!
   * All circles get diameter dimensions (`⌀`)!
   * All arcs and polyline fillet curves get radius dimensions (`R`)!
4. Done!

### Method 2: Post-Selection (Run First)
1. Type **`ADIM`** (or `AD`) and press **Enter**.
2. Select your objects on screen and press **Enter**.
3. Choose your mode: `Segments` (default), `Box`, or `Chain`.
4. Done!

---

## 🛡️ Smart CAD Features
* **Automatic Entity Recognition**: Distinguishes between straight lines, curved segments, arcs, and circles.
* **Smart Proportional Offsets**: Automatically calculates offset distances based on your active `DIMSCALE` and `DIMTXT` so text never overlaps geometry.
* **Respects Drawing Standards**: Uses your active `DIMSTYLE` and current active Layer.
* **Space Compatibility**: Works in Model Space, Paper Space Layouts, and inside the **Block Editor (`BEDIT`)**.
* **Clean Single Undo**: All created dimensions are bundled in one undo mark (`Ctrl+Z` reverses the operation in one click).

---

## 💻 Load in AutoCAD
```lisp
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Testing/AUTODIM/AUTODIM.lsp")
```
