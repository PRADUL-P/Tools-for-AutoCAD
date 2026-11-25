# 🚀 Published (Production-Ready) LISP Tools

This folder contains verified, production-grade AutoLISP tools that have been thoroughly tested for daily drafting workflows in AutoCAD.

---

## 📋 Published Tools Index

| Toolset | Core Commands | Description | Download | Documentation |
|---|---|---|---|---|
| **[XLINE](./XLINE/)** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | Multi-spaced construction lines with cursor direction detection, fast axis shortcuts. | [📥 `XLINE_ALL.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/XLINE/XLINE_ALL.lsp) | [View Details](./XLINE/README.md) |
| **[TCOUNT_PLUS](./TCOUNT_PLUS/)** | `TC`, `TCOUNTPLUS` | Advanced directional renumbering tool (Left/Right/Top/Bottom/Pick-order) with prefix, suffix & padding. | [📥 `TCOUNT_PLUS.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/TCOUNT_PLUS/TCOUNT_PLUS.lsp) | [View Details](./TCOUNT_PLUS/README.md) |
| **[ATTFIX](./ATTFIX/)** | `ATTFIX`, `AF` | Batch attribute synchronizer: Instantly updates Tag & Prompt based on Value (supports pre/post selection). | [📥 `ATTFIX.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/ATTFIX/ATTFIX.lsp) | [View Details](./ATTFIX/README.md) |
| **[BLOCK_RENAMER](./BLOCK_RENAMER/)** | `BRN`, `BNAME`, `BLOCKRENAME` | Fast block renamer: Click-to-rename on screen, dynamic block safe, batch Find & Replace, Prefix & Suffix. | [📥 `BLOCK_RENAMER.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/BLOCK_RENAMER/BLOCK_RENAMER.lsp) | [View Details](./BLOCK_RENAMER/README.md) |
| **[MTEXT_TO_ATTR](./MTEXT_TO_ATTR/)** | `MT2ATT`, `M2A`, `T2A` | Batch-converts Text and MText objects into Attribute Definitions (`ATTDEF`) in-place. Works inside the **Block Editor (`BEDIT`)**. | [📥 `MTEXT2ATTR.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/MTEXT_TO_ATTR/MTEXT2ATTR.lsp) | [View Details](./MTEXT_TO_ATTR/README.md) |
| **[SELECTION](./SELECTION/)** | `SA`, `SR` | High-speed selection of similar objects by layer, entity type, or block definition. | [📥 `Selection.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/SELECTION/Selection.lsp) | [View Details](./SELECTION/README.md) |
| **[HIDE_SHOW](./HIDE_SHOW/)** | `HH`, `HR` | Temporarily isolate/hide and restore drawing elements for clutter-free drafting. | [📥 `HIDE_SHOW.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/HIDE_SHOW/HIDE_SHOW.LSP) | [View Details](./HIDE_SHOW/README.md) |
| **[Create Similar](./Create%20Similar/)** | Fast creation shortcuts | Create matching elements based on selected entity properties. | [📥 `CREATE SIMILAR.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/Create%20Similar/CREATE%20SIMILAR.LSP) | [View Details](./Create%20Similar/) |

---

## 📥 How to Load
Use AutoCAD's `APPLOAD` command, select the `.lsp` file from any of the subfolders above, and click **Load**.
To keep them loaded permanently, add them to your **Startup Suite** (briefcase icon).
