# 🛠️ Tools for AutoCAD

[![Latest Release](https://img.shields.io/github/v/release/PRADUL-P/Tools-for-AutoCAD?color=brightgreen&label=Release&logo=github)](https://github.com/PRADUL-P/Tools-for-AutoCAD/releases)
[![AutoCAD Compatibility](https://img.shields.io/badge/AutoCAD-2018%20--%202026-blue?logo=autodesk)](https://github.com/PRADUL-P/Tools-for-AutoCAD)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 🔧 **Tools for AutoCAD** is a curated collection of production-grade **AutoLISP scripts and automation tools** designed to supercharge your CAD workflow. Built with a focus on **efficiency, precision, and practical field use**, this repository enables engineers, architects, and drafters to eliminate repetitive tasks, automate complex drawings, and speed up project delivery.

> 🧠 Unlock **CAD automation directly within AutoCAD** — 100% native AutoLISP, zero third-party plugins required. All published tools are **100% tested and verified** for daily production drafting.

---

## 🏗️ Repository Architecture

```
Tools-for-AutoCAD/
├── README.md                  ← Repository Overview
└── LISP/
    ├── README.md              ← LISP Directory & Index
    │
    ├── Published/             ← Production-Ready & Verified Tools
    │   ├── README.md
    │   ├── XLINE/             ← Multi-spaced construction lines (XVN, XHN, XH, XV, etc.)
    │   ├── TCOUNT_PLUS/       ← Advanced directional renumbering (TC, TCOUNTPLUS)
    │   ├── ATTFIX/            ← Instant Attribute Tag & Prompt synchronizer (AF, ATTFIX)
    │   ├── BLOCK_RENAMER/     ← Fast on-screen & batch block renamer (BRN, BNAME)
    │   ├── MTEXT_TO_ATTR/     ← In-place Text/MText to ATTDEF conversion (M2A, MT2ATT)
    │   ├── SELECTION/         ← Fast object selection (SA, SAT, SAL, SAC, etc.)
    │   ├── HIDE_SHOW/         ← Element isolation & visibility tools (HH, IL, HR)
    │   └── Create Similar/    ← Quick creation of matching objects (CS)
    │
    └── Testing/               ← Tools Under Active Evaluation & Testing
        ├── README.md
        └── AUTODIM/           ← Smart Auto-Dimensioning suite (ADIM, AUTODIM, AD)
```

---

## 🟢 Published & Tested Tools (Production-Ready)

All tools in this section have been personally tested and verified in real drafting workflows.  
👉 **[View All GitHub Releases](https://github.com/PRADUL-P/Tools-for-AutoCAD/releases)** | **[📦 Download All-in-One Bundle (ZIP)](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/All-Published-LISP-Tools.zip)**

> 💡 **Download Instructions**:
> - **Fastest (1-Click Download)**: Click any **`📥 .zip`** link below — your browser will instantly download the file!
> - **Direct `.lsp` file**: If clicking a **`.lsp`** link, **Right-Click ➜ "Save Link As..."** to save it directly to your folder.

| Toolset | Commands | Description | 1-Click Download | Direct LSP | Docs |
|---|---|---|---|---|---|
| **Construction Lines** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | Extended XLINE tools with custom spacing & cursor direction. | [📥 `XLINE.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/XLINE_ALL.zip) | [`XLINE_ALL.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/XLINE/XLINE_ALL.lsp) | [`/XLINE/`](./LISP/Published/XLINE/) |
| **Directional Renumbering** | `TC`, `TCOUNTPLUS` | Advanced directional renumbering (`LR`, `RL`, `TB`, `BT`, `SEL`) with prefix, suffix & zeros. | [📥 `TCOUNT_PLUS.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/TCOUNT_PLUS.zip) | [`TCOUNT_PLUS.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/TCOUNT_PLUS/TCOUNT_PLUS.lsp) | [`/TCOUNT_PLUS/`](./LISP/Published/TCOUNT_PLUS/) |
| **Attribute Synchronizer** | `ATTFIX`, `AF` | Instantly updates **Tag and Prompt** based on **Value** for all selected blocks. | [📥 `ATTFIX.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/ATTFIX.zip) | [`ATTFIX.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/ATTFIX/ATTFIX.lsp) | [`/ATTFIX/`](./LISP/Published/ATTFIX/) |
| **Block Renamer** | `BRN`, `BNAME`, `BLOCKRENAME` | Fast block renamer: Click-to-rename on screen, dynamic block safe, batch Find/Replace. | [📥 `BLOCK_RENAMER.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/BLOCK_RENAMER.zip) | [`BLOCK_RENAMER.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/BLOCK_RENAMER/BLOCK_RENAMER.lsp) | [`/BLOCK_RENAMER/`](./LISP/Published/BLOCK_RENAMER/) |
| **Text/MText to Attribute** | `MT2ATT`, `M2A`, `T2A` | In-place conversion of Text & MText to ATTDEF (preserves case, style, justification). | [📥 `MTEXT2ATTR.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/MTEXT2ATTR.zip) | [`MTEXT2ATTR.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/MTEXT_TO_ATTR/MTEXT2ATTR.lsp) | [`/MTEXT_TO_ATTR/`](./LISP/Published/MTEXT_TO_ATTR/) |
| **Selection Tools** | `SA`, `SAT`, `SAL`, `SAC`, `SAB`, `SLT`, `SAA` | Fast selection and filtering of similar objects by layer, entity type, color, block. | [📥 `Selection.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/Selection.zip) | [`Selection.lsp`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/SELECTION/Selection.lsp) | [`/SELECTION/`](./LISP/Published/SELECTION/) |
| **Visibility Management**| `HH`, `IL`, `HR` | Temporarily isolate/hide and restore visibility of selected drawing elements. | [📥 `HIDE_SHOW.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/HIDE_SHOW.zip) | [`HIDE_SHOW.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/HIDE_SHOW/HIDE_SHOW.LSP) | [`/HIDE_SHOW/`](./LISP/Published/HIDE_SHOW/) |
| **Create Similar** | `CS` | Quickly spawn new entities matching existing element properties (ADDSELECTED wrapper). | [📥 `CREATE_SIMILAR.zip`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/Downloads/CREATE_SIMILAR.zip) | [`CREATE SIMILAR.LSP`](https://github.com/PRADUL-P/Tools-for-AutoCAD/raw/main/LISP/Published/Create%20Similar/CREATE%20SIMILAR.LSP) | [`/Create Similar/`](./LISP/Published/Create%20Similar/) |

---

## 🟡 Testing Tools (Under Active Evaluation)

Tools in this section are in the **testing and refinement phase** awaiting validation before moving to `/Published/`:

| Toolset | Commands | Description | Folder |
|---|---|---|---|
| **Auto-Dimensioning** | `ADIM`, `AUTODIM`, `AD` | Smart Auto-Dimensioning suite: Bounding Box (overall W/H), Segments (each edge), and Chain (continuous grid). | [`/LISP/Testing/AUTODIM/`](./LISP/Testing/AUTODIM/) |

---

## 🔮 Upcoming Features (Roadmap)

*Note: The tools below are currently in research & development and are planned for future release:*

* **Two-Way Live Section Tag Synchronizer (`TWO_WAY_SYNC`)**:  
  Bidirectional real-time live synchronization between matching callout/section tags across drawings and viewports using AutoLISP Object Reactors.

* **Dynamic Field-Based Section Linker (`LINK_TEXT`)**:  
  Automated text-linking using native AutoCAD DWG Field codes (`%<\AcObjProp ...>%`) across horizontal, vertical, and detail sections.

---

## 🚀 How to Load & Use

### Method 1: APPLOAD (Recommended)
1. In AutoCAD, type `APPLOAD` and press **Enter**.
2. Navigate to the desired `.lsp` file inside the `LISP/Published/` or `LISP/Testing/` subfolders.
3. Click **Load**.
4. *(Optional)* Add production scripts to your **Startup Suite** (briefcase icon) to keep them loaded automatically in every drawing session.

### Method 2: Command Line Direct Load
```lisp
;; Production Tools
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/ATTFIX/ATTFIX.lsp")
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/BLOCK_RENAMER/BLOCK_RENAMER.lsp")
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/MTEXT_TO_ATTR/MTEXT2ATTR.lsp")
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/TCOUNT_PLUS/TCOUNT_PLUS.lsp")
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Published/XLINE/XLINE_ALL.lsp")

;; Testing Tools
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Testing/AUTODIM/AUTODIM.lsp")
```
