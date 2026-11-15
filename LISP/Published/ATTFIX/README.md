# 🏷️ ATTFIX – Instant Attribute Tag & Prompt Synchronizer

A productivity AutoLISP tool for AutoCAD that eliminates the repetitive chore of editing block attributes.

Whenever you run `ATTFIX` and click an attribute, **the Tag and Prompt instantly change to match that attribute's current Value as it is**—no manual re-typing, no dialog boxes, in **one single click**!

---

## ⚡ How It Works (1-Click Sync)

In AutoCAD:
- You have blocks where attributes already have values (e.g. `101`, `DOOR-A`, `Kitchen`, `PL-01`).
- You run **`AF`** (or `ATTFIX`).
- **Just click the attribute.**
- **BAM!** The **Tag** and **Prompt** immediately change to that value **as it is**!
- You can keep clicking attribute after attribute continuously. Press **Enter** or **Esc** when finished.

---

## 🛠️ What Gets Updated Behind the Scenes

1. **Current Attribute Reference (`ATTRIB`)**:
   - `TagString` $\rightarrow$ set to the Value **as it is**.
2. **Block Definition (`AcDbBlockTableRecord` / `ATTDEF`)**:
   - `TagString` $\rightarrow$ set to the Value **as it is**.
   - `PromptString` $\rightarrow$ set to the Value **as it is**.
   - `TextString` (default) $\rightarrow$ set to the Value **as it is**.
3. **All Existing Block Instances in the Drawing**:
   - Their `TagString` is updated to match the definition so the entire drawing stays clean and consistent **without running destructive `ATTSYNC`**!

---

## 🚀 Commands & Modes

| Command | Alias | Mode | Description |
|---|---|---|---|
| `ATTFIX` | **`AF`** | **1-Click Sync** *(Default)* | **Click any attribute $\rightarrow$ Tag and Prompt instantly change to that Value as it is!** Continuous loop. |
| `ATTFIXEDIT` | **`AFE`** | **Edit Mode** | Pick an attribute, type a new value $\rightarrow$ Value, Tag, and Prompt all change to that new value as it is. |
| `ATTFIXALL` | **`AFA`** | **Global Mode** | Click an attribute $\rightarrow$ Tag and Prompt change to that Value as it is, **AND updates that Value across ALL instances** of that block in the drawing. |

> 💡 **Quick Switch inside the Command**: While `AF` is running, you can type **`E`** (Edit), **`G`** (Global), or **`S`** (Sync) directly at the selection prompt to switch modes on the fly!

---

## 💻 How to Load & Run in AutoCAD

1. In AutoCAD, load the script:
   ```lisp
   (load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/ATTFIX/ATTFIX.lsp")
   ```
   *(or use `APPLOAD` and pick `ATTFIX.lsp`)*

2. Type **`AF`** and press **Enter**.
3. Click the attribute.
4. Output:
   ```text
   ✅ SUCCESS for Block [DOOR_TAG]:
      • Value  : "101"
      • Tag    : "101" (changed to Value as it is)
      • Prompt : "101" (changed to Value as it is)
      • Block Definition: ATTDEF Tag & Prompt updated in Block Table.
      • Tag Sync: 4 instance(s) synced to Tag "101".
   ```
5. Click the next attribute, or press **Enter** to finish!
