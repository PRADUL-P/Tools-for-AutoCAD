# 🏷️ ATTFIX – Batch Attribute Tag & Prompt Synchronizer

Instantly updates block attribute **TAGs** and **PROMPTs** based on their current **VALUE** "as it is"!

Supports selection **BEFORE or AFTER** entering the command (batch window-select, crossing, pick, or `ALL`).

---

## ⚡ How It Works

### Option 1: Selection BEFORE Command (Pre-selection / Pickfirst)
1. Select blocks or attributes in AutoCAD (window-select, crossing, or `Ctrl+A`).
2. Type **`AF`** (or `ATTFIX`) and press **Enter** / **Spacebar**.
3. **Instantly:** All selected attributes have their **Tag** and **Prompt** changed to match their **Value as it is**!

### Option 2: Selection AFTER Command
1. Type **`AF`** (or `ATTFIX`) and press **Enter**.
2. Select your blocks or attributes (use window, crossing, click, or type `ALL`).
3. Press **Enter**.
4. **Instantly:** All selected attributes have their **Tag** and **Prompt** changed to match their **Value as it is**!

---

## 🛠️ What Gets Updated
- **Attribute Reference (`ATTRIB`)**: Tag is set to the attribute's current Value.
- **Block Table Definition (`ATTDEF`)**: The underlying block definition's Tag and Prompt are updated in the Block Table.
- **Block Editor (`BEDIT`)**: Also works directly on `ATTDEF` objects inside the Block Editor.
- **No Destructive `ATTSYNC`**: Preserves custom attribute positions, rotations, and manual adjustments.
- **Single Undo**: One `Ctrl+Z` reverses the entire batch operation cleanly.

---

## 🚀 Commands

| Command | Shortcut | Description |
|---|---|---|
| `ATTFIX` | **`AF`** | Instantly syncs Tag and Prompt to Value for all selected blocks/attributes (pre-selection or post-selection). |

---

## 💻 Load in AutoCAD
```lisp
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/ATTFIX/ATTFIX.lsp")
```
