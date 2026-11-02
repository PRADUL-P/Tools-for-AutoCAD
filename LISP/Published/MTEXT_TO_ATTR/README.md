# MTEXT to Attribute Definition (MT2ATT)

A powerful AutoLISP tool for AutoCAD to convert multiple **MText** objects into native **Attribute Definitions (`ATTDEF`)** in-place with a single command.

---

## 🚀 Key Features

- **Block Editor (`BEDIT`) Compatible**: Works seamlessly inside the Block Editor as well as standard Model Space and Paper Space. It automatically detects the active block definition and creates the attribute definitions inside it.
- **Smart Tag Generation**: Automatically generates the Attribute Tag directly from the original MText string (e.g., text saying `ROOM NUMBER` automatically becomes Tag `ROOM_NUMBER`).
- **AutoCAD Tag Sanitization**: Automatically removes illegal characters, strips MText formatting codes, and replaces spaces with underscores.
- **Collision Prevention**: If multiple selected MText objects share the exact same text, it automatically appends incremental suffixes (`NAME`, `NAME_2`, `NAME_3`) to ensure unique tags within the block.
- **Preserves Formatting & Position**:
  - Exact insertion coordinate and justification / alignment (Top-Left, Middle-Center, Bottom-Right, etc.).
  - Text style (`STYLE`).
  - Text height (`HEIGHT`).
  - Rotation angle (`ROTATION`).
  - Layer (`LAYER`).
  - Explicit entity color (if set).
- **Undo Support**: Groups the entire operation into a single undo mark (`Ctrl+Z`).

---

## 📥 How to Load

### Option 1: Load via APPLOAD
1. In AutoCAD, type `APPLOAD` and press **Enter**.
2. Browse to and select `MTEXT2ATTR.lsp`.
3. Click **Load**.

### Option 2: Load via Command Line
Run the following in the AutoCAD command prompt:
```lisp
(load "MTEXT2ATTR.lsp")
```
*(Or specify the full path to `MTEXT2ATTR.lsp`)*

---

## 🎯 How to Use

1. Type `MT2ATT` in the AutoCAD command line and press **Enter**.
2. Select one or more **MText** objects (window or crossing selection supported).
3. The script automatically:
   - Reads each MText's properties and content.
   - Creates an equivalent Attribute Definition (`ATTDEF`) at the exact same location.
   - Deletes the original MText.

> **Tip for Block Editor (`BEDIT`)**:  
> After converting your MText objects to attributes, save and close the Block Editor (`BCLOSE`). Run the AutoCAD `ATTSYNC` command on your block references to synchronize existing insertions with the newly created attributes.

---

## 📋 Command Summary

| Command | Description |
|---|---|
| `MT2ATT` | Batch convert selected MText objects to Attribute Definitions |
