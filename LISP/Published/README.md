# 🚀 Published (Production-Ready) LISP Tools

This folder contains verified, production-grade AutoLISP tools that have been thoroughly tested for daily drafting workflows in AutoCAD.

---

## 📋 Published Tools Index

| Toolset | Core Commands | Description | 1-Click Download | Direct LSP | Docs |
|---|---|---|---|---|---|
| **[XLINE](./XLINE/)** | `XVN`, `XHN`, `XH`, `XV` | Multi-spaced construction lines with cursor direction detection. | [📥 `XLINE.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/XLINE_ALL.zip) | [`XLINE_ALL.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/XLINE/XLINE_ALL.lsp) | [View](./XLINE/README.md) |
| **[TCOUNT_PLUS](./TCOUNT_PLUS/)** | `TC`, `TCOUNTPLUS` | Advanced directional renumbering (LR, RL, TB, BT, SEL) with padding. | [📥 `TCOUNT_PLUS.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/TCOUNT_PLUS.zip) | [`TCOUNT_PLUS.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/TCOUNT_PLUS/TCOUNT_PLUS.lsp) | [View](./TCOUNT_PLUS/README.md) |
| **[ATTFIX](./ATTFIX/)** | `ATTFIX`, `AF` | Batch attribute synchronizer: Updates Tag & Prompt to Value. | [📥 `ATTFIX.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/ATTFIX.zip) | [`ATTFIX.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/ATTFIX/ATTFIX.lsp) | [View](./ATTFIX/README.md) |
| **[BLOCK_RENAMER](./BLOCK_RENAMER/)** | `BRN`, `BNAME` | Fast block renamer: Click-to-rename on screen, dynamic block safe. | [📥 `BLOCK_RENAMER.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/BLOCK_RENAMER.zip) | [`BLOCK_RENAMER.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/BLOCK_RENAMER/BLOCK_RENAMER.lsp) | [View](./BLOCK_RENAMER/README.md) |
| **[MTEXT_TO_ATTR](./MTEXT_TO_ATTR/)** | `MT2ATT`, `M2A`, `T2A` | In-place conversion of Text & MText to ATTDEF (preserves case). | [📥 `MTEXT2ATTR.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/MTEXT2ATTR.zip) | [`MTEXT2ATTR.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/MTEXT_TO_ATTR/MTEXT2ATTR.lsp) | [View](./MTEXT_TO_ATTR/README.md) |
| **[SELECTION](./SELECTION/)** | `SA`, `SR` | High-speed selection of similar objects by layer, type, block. | [📥 `Selection.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/Selection.zip) | [`Selection.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/SELECTION/Selection.lsp) | [View](./SELECTION/README.md) |
| **[HIDE_SHOW](./HIDE_SHOW/)** | `HH`, `HR` | Temporarily isolate/hide and restore drawing elements. | [📥 `HIDE_SHOW.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/HIDE_SHOW.zip) | [`HIDE_SHOW.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/HIDE_SHOW/HIDE_SHOW.LSP) | [View](./HIDE_SHOW/README.md) |
| **[Create Similar](./Create%20Similar/)** | `CS` | Create matching elements based on selected entity properties. | [📥 `CREATE_SIMILAR.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/CREATE_SIMILAR.zip) | [`CREATE SIMILAR.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/Create%20Similar/CREATE%20SIMILAR.LSP) | [View](./Create%20Similar/) |

---

## 📥 How to Load
Use AutoCAD's `APPLOAD` command, select the `.lsp` file from any of the subfolders above, and click **Load**.
To keep them loaded permanently, add them to your **Startup Suite** (briefcase icon).
