# Dynamic Text & Attribute Linker (`LINK_TEXT`)

A dedicated AutoLISP tool for AutoCAD to dynamically link text or attribute tags across multiple sections (e.g. horizontal, vertical, or diagonal). 

Whenever you update a number in the primary section, the linked copy in the secondary section **automatically updates upon `REGEN`, `SAVE`, or `PLOT`** using native AutoCAD Fields.

---

## 💡 The Problem It Solves

When drafting sections (like structural rebar layouts, grid callouts, or architectural elevations), you often have:
- A horizontal section numbered `1, 2, 3 ... 11`
- A vertical or diagonal section numbered `1, 2, 3 ... 11`

Manually retyping or updating numbers in both places causes errors and wasted time. This tool establishes a permanent, dynamic link between them using native DWG Fields (`%<\AcObjProp ...>%`).

---

## ⚡ Commands Included

| Command | Best For | How It Works |
|---|---|---|
| **`LINKBATCH`** | **Batch Linking (Fastest)** | Window-select all source numbers (horizontal), then window-select all target numbers (vertical). Automatically sorts them (Left-to-Right / Top-to-Bottom) and links all 11 pairs in 1 second! |
| **`LINK1`** | **One-by-One Linking** | Click a source text $\rightarrow$ click a target text. Continues in a loop until you press `Enter` or `Esc`. |
| **`COPYLINK`** | **Copy & Place** | Click a source text or block $\rightarrow$ pick a point in your other section to create a dynamic linked clone. |

---

## 🚀 How to Use `LINKBATCH` (For your 1–11 sections)

1. Load the script:
   ```lisp
   (load "LINK_TEXT.lsp")
   ```
2. Run command:
   ```text
   LINKBATCH
   ```
3. **Prompt 1**: Window-select the 11 numbers in your horizontal section.
4. **Prompt 2**: Window-select the 11 numbers in your vertical section.
5. **Done!** The tool automatically:
   - Sorts the horizontal numbers left-to-right (`1` to `11`).
   - Sorts the vertical numbers top-to-bottom (`1` to `11`).
   - Dynamically pairs `1 -> 1`, `2 -> 2`, ... `11 -> 11`.
   - Regenerates the view immediately.

Whenever you edit any number in the horizontal section (e.g. change `5` to `5A`), simply type **`REGEN`** (or save/plot) and the vertical section updates automatically!

---

## 📥 Supported Entity Types
- `MTEXT`
- `TEXT` (Single-line DText)
- `ATTRIB` (Block Attributes)
- `INSERT` (Blocks containing attributes)
- Works even if the two sections use different block definitions or text styles!
