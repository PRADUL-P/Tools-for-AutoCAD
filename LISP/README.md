# 🛠️ AutoCAD LISP Directory

Welcome to the **Tools-for-AutoCAD** LISP catalog!

Following rigorous engineering standards:
* **[`/Published/`](./Published/)**: Verified, production-grade tools tested directly by the author for daily drafting.
* **[`/Testing/`](./Testing/)**: Newly created tools undergoing personal evaluation and testing before publication.

---

## 📁 Repository Structure

```
LISP/
├── README.md                  ← You are here
├── Published/                 ← Production-Ready Tools (Tested & Verified)
│   ├── README.md
│   ├── XLINE/                 ← Multi-spaced construction lines & shortcuts (XVN, XHN, etc.)
│   ├── TCOUNT_PLUS/           ← Advanced directional renumbering tool (TC, TCOUNTPLUS)
│   ├── ATTFIX/                ← Instant Attribute Value, Tag & Prompt synchronizer (AF, ATTFIX)
│   ├── BLOCK_RENAMER/         ← Fast on-screen & batch block renamer (BRN, BNAME)
│   ├── MTEXT_TO_ATTR/         ← In-place Text/MText to ATTDEF conversion (M2A, MT2ATT)
│   ├── SELECTION/             ← Selection helpers (SA, SAT, SAL, SAC, etc.)
│   ├── HIDE_SHOW/             ← Hide/isolate/restore visibility tools (HH, IL, HR)
│   └── Create Similar/        ← Create matching elements (CS)
└── Testing/                   ← Tools Under Testing & Evaluation
    ├── README.md
    └── AUTODIM/               ← Smart Auto-Dimensioning suite (ADIM, AUTODIM, AD)
```

---

## 🟢 Published & Tested Tools Index

All tools below are located in [`/Published/`](./Published/) and verified for daily production:

| Toolset | Core Commands | Description | 1-Click Download | Direct LSP | Docs |
|---|---|---|---|---|---|
| **[XLINE](./Published/XLINE/)** | `XVN`, `XHN`, `XH`, `XV` | Multi-spaced construction lines with cursor direction detection. | [📥 `XLINE.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/XLINE_ALL.zip) | [`XLINE_ALL.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/XLINE/XLINE_ALL.lsp) | [View](./Published/XLINE/README.md) |
| **[TCOUNT_PLUS](./Published/TCOUNT_PLUS/)** | `TC`, `TCOUNTPLUS` | Advanced directional renumbering (LR, RL, TB, BT, SEL) with padding. | [📥 `TCOUNT_PLUS.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/TCOUNT_PLUS.zip) | [`TCOUNT_PLUS.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/TCOUNT_PLUS/TCOUNT_PLUS.lsp) | [View](./Published/TCOUNT_PLUS/README.md) |
| **[ATTFIX](./Published/ATTFIX/)** | `ATTFIX`, `AF` | Batch attribute synchronizer: Updates Tag & Prompt to Value. | [📥 `ATTFIX.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/ATTFIX.zip) | [`ATTFIX.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/ATTFIX/ATTFIX.lsp) | [View](./Published/ATTFIX/README.md) |
| **[BLOCK_RENAMER](./Published/BLOCK_RENAMER/)** | `BRN`, `BNAME` | Fast block renamer: Click-to-rename on screen, dynamic block safe. | [📥 `BLOCK_RENAMER.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/BLOCK_RENAMER.zip) | [`BLOCK_RENAMER.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/BLOCK_RENAMER/BLOCK_RENAMER.lsp) | [View](./Published/BLOCK_RENAMER/README.md) |
| **[MTEXT_TO_ATTR](./Published/MTEXT_TO_ATTR/)** | `MT2ATT`, `M2A`, `T2A` | In-place conversion of Text & MText to ATTDEF (preserves case). | [📥 `MTEXT2ATTR.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/MTEXT2ATTR.zip) | [`MTEXT2ATTR.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/MTEXT_TO_ATTR/MTEXT2ATTR.lsp) | [View](./Published/MTEXT_TO_ATTR/README.md) |
| **[SELECTION](./Published/SELECTION/)** | `SA`, `SR` | High-speed selection of similar objects by layer, type, block. | [📥 `Selection.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/Selection.zip) | [`Selection.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/SELECTION/Selection.lsp) | [View](./Published/SELECTION/README.md) |
| **[HIDE_SHOW](./HIDE_SHOW/)** | `HH`, `HR` | Temporarily isolate/hide and restore drawing elements. | [📥 `HIDE_SHOW.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/HIDE_SHOW.zip) | [`HIDE_SHOW.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/HIDE_SHOW/HIDE_SHOW.LSP) | [View](./Published/HIDE_SHOW/README.md) |
| **[Create Similar](./Published/Create%20Similar/)** | `CS` | Create matching elements based on selected entity properties. | [📥 `CREATE_SIMILAR.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/CREATE_SIMILAR.zip) | [`CREATE SIMILAR.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/Create%20Similar/CREATE%20SIMILAR.LSP) | [View](./Published/Create%20Similar/) |

---

## 🟡 Testing Tools (Under Active Evaluation)

Tools in [`/Testing/`](./Testing/) are awaiting field testing and validation before graduation to `/Published/`:

| Toolset | Core Commands | Description | Documentation |
|---|---|---|---|
| **[AUTODIM](./Testing/AUTODIM/)** | `ADIM`, `AUTODIM`, `AD` | Multi-mode auto-dimensioning suite: Bounding Box (overall W/H), Segments (each edge), and Chain (continuous grid). | [View Details](./Testing/AUTODIM/README.md) |

---

## 🔮 Upcoming Features (Roadmap)

* **Two-Way Live Section Tag Synchronizer (`TWO_WAY_SYNC`)**:  
  Bidirectional real-time live synchronization between matching callout/section tags across drawings and viewports using AutoLISP Object Reactors.

* **Dynamic Field-Based Section Linker (`LINK_TEXT`)**:  
  Automated text-linking using native AutoCAD Field codes (`%<\AcObjProp ...>%`) across horizontal, vertical, and detail sections.
