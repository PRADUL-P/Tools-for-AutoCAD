# 🏷️ BLOCK RENAMER (BRN / BNAME)

A high-speed block renaming utility for AutoCAD. Replace AutoCAD's slow, multi-step native `RENAME` dialog with **fast on-screen clicking, pre-selection, and batch renaming**!

---

## ⚡ Why Use BLOCK RENAMER?

In native AutoCAD, renaming a block requires:
1. Typing `RENAME` or finding the dialog box.
2. Scrolling through a massive list of hundreds of block names.
3. Guessing which internal name corresponds to the block on your screen.
4. Dealing with errors when renaming dynamic blocks.

**`BLOCK RENAMER` solves this instantly:**
- **Click-to-Rename**: Click any block in the drawing $\rightarrow$ type the new name $\rightarrow$ renamed!
- **Dynamic Block Safe**: Automatically detects the master `EffectiveName` of anonymous (`*U...`) dynamic blocks.
- **Batch Find & Replace (`F`)**: Rename groups of blocks in one step (e.g., change `_OLD` to `_NEW` or `A_` to `ARCH_`).
- **Batch Prefix (`P`) & Suffix (`S`)**: Prepend or append text to selected blocks.
- **Safety Checks**: Blocks illegal characters and prevents accidental overwrites of existing blocks.

---

## 🚀 Commands

| Command | Shortcut | Description |
|---|---|---|
| `BRN` | **`BNAME`** | Main command: Click to rename on screen, or use Find/Replace, Prefix, and Suffix options. |
| `BLOCKRENAME` | — | Full command alias. |

---

## 🎯 How to Use

### 1. Click-to-Rename (Fastest)
1. Type **`BRN`** (or `BNAME`).
2. Click any block on your drawing.
3. It displays the current name:
   ```text
   📌 Block: [DOOR_SINGLE_900]
   Enter new name for block <DOOR_SINGLE_900>: 
   ```
4. Enter the new name (e.g. `D01_900`) and press **Enter**.
5. All instances in the drawing immediately reflect the new name!
6. Click the next block, or press **Enter** to exit.

### 2. Pre-Selection (Pickfirst)
1. Select a block on screen.
2. Type **`BRN`** and press **Enter**.
3. Type the new name and press **Enter**!

### 3. Batch Find & Replace
1. Type **`BRN`**.
2. Type **`F`** (for Find).
3. Enter the text to search for (e.g. `_REV1`) and the replacement text (e.g. `_REV2`).
4. All matching block names across the entire drawing are updated instantly!

### 4. Batch Prefix or Suffix
1. Type **`BRN`**.
2. Type **`P`** (Prefix) or **`S`** (Suffix).
3. Window-select the blocks.
4. Enter the prefix (e.g. `ELEC_`) or suffix (e.g. `_3D`).
5. All selected unique block definitions are renamed!

---

## 💻 Load in AutoCAD
```lisp
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/BLOCK_RENAMER/BLOCK_RENAMER.lsp")
```
*(Or load via `APPLOAD` and add to your Startup Suite).*
