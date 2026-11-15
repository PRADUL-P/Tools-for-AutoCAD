# Text & MTEXT to Attribute Definition (MT2ATT / M2A)

A powerful AutoLISP tool for AutoCAD to batch-convert **single-line TEXT** and **multi-line MTEXT** objects into native **Attribute Definitions (`ATTDEF`)** in-place with a single command.

---

## 🚀 Key Features

- **Supports Both TEXT & MTEXT**: Seamlessly handles single-line text (`AcDbText`) and multi-line text (`AcDbMText`).
- **Selection Before or After**: Supports pre-selection (select text first, then type `M2A`) or post-selection (type `M2A`, then window-select).
- **Block Editor (`BEDIT`) Compatible**: Works seamlessly inside the Block Editor as well as standard Model Space and Paper Space. It automatically detects the active block definition and creates the attribute definitions inside it.
- **Smart Tag Generation**: Automatically generates the Attribute Tag directly from the original text string (e.g., text saying `ROOM NUMBER` automatically becomes Tag `ROOM_NUMBER`).
- **AutoCAD Tag Sanitization**: Automatically removes illegal characters, strips MText formatting codes, and replaces spaces with underscores.
- **Collision Prevention**: If multiple selected text objects share the exact same text, it automatically appends incremental suffixes (`NAME`, `NAME_2`, `NAME_3`) to ensure unique tags within the block.
- **Preserves Formatting & Position**:
  - Exact insertion coordinate and justification / alignment (Left, Center, Right, Middle, Top-Left, Middle-Center, Bottom-Right, etc.).
  - Text style (`STYLE`).
  - Text height (`HEIGHT`).
  - Rotation angle (`ROTATION`).
  - Layer (`LAYER`).
  - Explicit entity color (if set).
  - Width Factor (`ScaleFactor`) and Oblique angle.
- **Undo Support**: Groups the entire operation into a single undo mark (`Ctrl+Z`).

---

## ⚡ Commands

| Command | Shortcut | Description |
|---|---|---|
| `MT2ATT` | **`M2A`** | Convert selected Text or MText objects into Attribute Definitions (`ATTDEF`). |
| `T2A` | `TXT2ATT` | Text-specific shortcut alias for `M2A`. |

---

## 📥 How to Load & Use

### In AutoCAD:
1. Load the script:
   ```lisp
   (load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/MTEXT_TO_ATTR/MTEXT2ATTR.lsp")
   ```
2. Type **`M2A`** or **`MT2ATT`**.
3. Select your Text or MText objects (or select them before typing `M2A`).
4. Instantly converted to `ATTDEF` in-place!

> **Tip for Block Editor (`BEDIT`)**:  
> After converting your Text/MText objects to attributes inside BEDIT, save and close the Block Editor (`BCLOSE`). Run the AutoCAD `ATTSYNC` command on your block references to synchronize existing insertions with the newly created attributes.
