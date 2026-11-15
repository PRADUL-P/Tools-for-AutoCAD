# 🏷️ ATTFIX – Attribute Value, Tag & Prompt Synchronizer

A productivity AutoLISP tool for AutoCAD that eliminates the repetitive chore of editing block attributes.

Whenever you update an attribute's value with `ATTFIX`, **all three components** (the **Value**, the **Tag**, and the **Prompt**) are automatically synchronized to that name in a single quick step!

---

## ⚡ Why Use ATTFIX?

In default AutoCAD, renaming an attribute requires multiple tedious steps:
1. Double-clicking the block reference only edits the **Value** (`TextString`). The Tag and Prompt remain unchanged.
2. Changing the **Tag** or **Prompt** requires opening the **Block Editor (`BEDIT`)**, double-clicking the `ATTDEF`, and modifying Tag, Prompt, and Default separately.
3. Once back in model space, the changes don't appear until you run **`ATTSYNC`**—which often **wipes out custom attribute positions, rotations, and manual adjustments** across all your drawings.

**`ATTFIX` solves this entirely:**
- Pick an attribute directly in Model Space, Paper Space, or inside `BEDIT`.
- Enter the new name.
- **Value**, **Tag**, and **Prompt** are updated simultaneously.
- Block definition (`AcDbBlockTableRecord`) and all existing instances are updated in memory without running destructive `ATTSYNC`.

---

## 📋 Features

- 🎯 **All-in-One Synchronization**: Sets Value (`TextString`), Tag (`TagString`), and Prompt (`PromptString`) together.
- 🧱 **Block Definition Sync**: Automatically updates the underlying `ATTDEF` in the block table record.
- 🔄 **Safe Instance Sync**: Updates the `TagString` on all existing block references in the drawing so they stay 100% consistent with the definition without resetting custom rotations or positions.
- ⚡ **Dynamic Block Compatible**: Seamlessly resolves anonymous block instances (`*U...`) to their true master `EffectiveName`.
- 📐 **Block Editor (`BEDIT`) Compatible**: Works on attribute definitions (`ATTDEF`) directly when creating or designing blocks.
- 🌐 **Global Mode (`ATTFIXALL`)**: An optional command to propagate the new value across all instances of that block in one click (ideal for title block revisions, project numbers, etc.).
- 🔁 **Continuous Loop**: Keep clicking attributes one after another; press `Enter` or `Esc` when done.
- 🛡️ **Clean Undo Mark**: Wrapped in a single `vla-StartUndoMark`/`vla-EndUndoMark` group (`Ctrl+Z` reverses the operation cleanly).

---

## 🚀 Commands

| Command | Shortcut | Description |
|---|---|---|
| `ATTFIX` | **`AF`** | **Single Mode (Recommended)**: Updates the picked attribute's Value, Tag, and Prompt. Syncs definition and existing tags across drawing. |
| `ATTFIXALL` | **`AFA`** | **Global Mode**: Same as `ATTFIX`, but also updates the **Value** across **ALL instances** of that block in the drawing. |

---

## 💻 How to Use

1. Load the script in AutoCAD:
   ```text
   APPLOAD -> select ATTFIX.lsp -> Load
   ```
   *(or type `(load "ATTFIX.lsp")` in the command line)*

2. Type **`AF`** or **`ATTFIX`**.
3. Click on the attribute you want to update.
4. The command displays current block, tag, and value details:
   ```text
   📌 Found Attribute:
      • Block : DOOR_TAG
      • Tag   : D_NUM
      • Value : "101"
   ```
5. Enter the new name (e.g., `D_102` or `ROOM_NAME`) and press **Enter**:
   ```text
   ✅ SUCCESS for Block [DOOR_TAG]:
      • Value  : "D_102"
      • Tag    : D_102
      • Prompt : "D_102"
      • Definition Updated: Tag & Prompt synced in Block Table.
      • Tag Sync: 5 block reference(s) synced to Tag [D_102].
   ```
6. Click the next attribute, or press **Enter** / **Esc** to finish.

---

## 🏷️ Tag Formatting & Sanitization
AutoCAD tags do not permit spaces. `ATTFIX` automatically sanitizes names for tags:
- If you enter `"ROOM NUMBER"`:
  - **Value**: `"ROOM NUMBER"`
  - **Prompt**: `"ROOM NUMBER"`
  - **Tag**: `"ROOM_NUMBER"` (spaces converted to underscores, capitalised)
