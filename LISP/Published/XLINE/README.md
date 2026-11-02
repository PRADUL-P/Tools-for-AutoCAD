# 📐 Extended XLINE Tools

A collection of AutoLISP commands for drawing and arraying **Construction Lines (`XLINE`)** quickly and accurately in AutoCAD.

---

## ⚡ Available Commands

| Command | Description |
|---|---|
| **`XVN`** | **Array Vertical XLINEs** with user-defined count, spacing, and cursor direction |
| **`XHN`** | **Array Horizontal XLINEs** with user-defined count, spacing, and cursor direction |
| **`XH`** | Quick Horizontal XLINE |
| **`XV`** | Quick Vertical XLINE |
| **`XA`** | Angled XLINE |
| **`XB`** | Bisecting XLINE |
| **`XO`** | Offset XLINE |

---

## 🚀 How `XVN` Works (Array Vertical XLINEs)

1. Type `XVN` in the command line.
2. **Step 1 - Start Point**: Click where you want the first vertical construction line.
3. **Step 2 - Count**: Enter the total number of lines you want (e.g., `5`).
4. **Step 3 - Spacing & Direction**:
   - Move your mouse to the **Right** and enter distance (e.g. `200`) $\rightarrow$ lines space to the right.
   - Move your mouse to the **Left** and enter distance (e.g. `200`) $\rightarrow$ lines space to the left.
   - Or click an existing snap point to measure the spacing directly!

All $N$ lines are drawn perfectly vertical with exact spacing in the direction of your mouse!

---

## 📥 How to Load

```lisp
(load "XLINE_ALL.lsp")
```
*(Or use `APPLOAD` in AutoCAD)*
