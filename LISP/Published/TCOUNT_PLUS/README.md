# 🔢 TCOUNT_PLUS – Advanced Directional Renumbering Tool

An enhanced, high-precision replacement for AutoCAD's native Express Tool `TCOUNT`. Renumber text, MText, and block attributes in **any direction** with custom prefixes, suffixes, and leading zeros.

---

## ⚡ Why TCOUNT_PLUS is Better Than Native TCOUNT

| Feature | Native `TCOUNT` (Express Tools) | **`TCOUNT_PLUS`** |
|---|---|---|
| **Directions** | Only X (left-right) or Y (top-bottom) | **Any: Left-to-Right (`LR`), Right-to-Left (`RL`), Top-to-Bottom (`TB`), Bottom-to-Top (`BT`), or Selection Order (`SEL`)** |
| **Prefix & Suffix** | Only one at a time | **Both simultaneously** (e.g. Prefix `SEC-`, Suffix `-A` $\rightarrow$ `SEC-1-A`) |
| **Leading Zeros** | Not supported | **Supported**: `None` (1), `2-digits` (01), `3-digits` (001), `4-digits` (0001) |
| **Block Attributes** | No (text only) | **Yes! Full support for Block Attributes (`ATTRIB`)** |
| **Placement Modes** | Overwrite, Prefix, Suffix | Overwrite, Prefix, Suffix |
| **Undo** | Cluttered multi-step undo | **Clean Single Undo Mark** (one `Ctrl+Z` undoes everything) |

---

## 🚀 How to Use

1. Load the script:
   ```lisp
   (load "TCOUNT_PLUS.lsp")
   ```
2. Type either:
   ```text
   TC
   ```
   *(or `TCOUNTPLUS`)*

3. **Select objects**: Window-select or click your text, MText, or blocks with attributes.
4. **Choose Direction**:
   - `LR` : Left $\rightarrow$ Right (X ascending)
   - `RL` : Right $\rightarrow$ Left (X descending)
   - `TB` : Top $\rightarrow$ Bottom (Y descending)
   - `BT` : Bottom $\rightarrow$ Top (Y ascending)
   - `SEL`: Exact order you picked the items
5. **Choose Mode**:
   - `Overwrite` : Completely replaces the text with the new numbering
   - `Prefix`    : Puts the number before existing text
   - `Suffix`    : Puts the number after existing text
6. **Enter Start & Increment**: (e.g. Start at `1`, Increment `1`)
7. **Leading Zeros**: `None`, `2-digits` (`01, 02..`), `3-digits` (`001..`), or `4-digits`
8. **Optional Prefix / Suffix**: Enter text (e.g., Prefix `COL-`, Suffix `-B`), or press Enter to skip.

---

## 💡 Practical Examples

- **Renumbering structural grid columns right-to-left**:  
  Select columns $\rightarrow$ choose `RL` $\rightarrow$ Prefix `C-` $\rightarrow$ Result: `C-1`, `C-2`, `C-3` from right to left!
- **Renumbering section rebar bars bottom-to-top**:  
  Select rebar labels $\rightarrow$ choose `BT` $\rightarrow$ Result: `1, 2, 3... 11` numbered from bottom to top!
- **Adding Sheet prefixes**:  
  Choose `Prefix` mode $\rightarrow$ `SH-` $\rightarrow$ Result: `SH-01`, `SH-02`!
