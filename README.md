# 🛠️ Tools for AutoCAD

> 🔧 **Tools for AutoCAD** is a curated collection of production-grade **AutoLISP scripts and automation tools** designed to supercharge your CAD workflow. Built with a focus on **efficiency, precision, and practical field use**, this repository enables engineers, architects, and drafters to eliminate repetitive tasks, automate complex drawings, and speed up project delivery.

> 🧠 Unlock **CAD automation directly within AutoCAD** — 100% native AutoLISP, zero third-party plugins required.

---

## 💡 Toolset Overview

| Category | Commands | Description | Folder |
|---|---|---|---|
| **Construction Lines** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | Extended XLINE tools. Includes **arraying multiple vertical/horizontal construction lines** with custom spacing and mouse-direction detection. | [`/LISP/XLINE/`](./LISP/XLINE/) |
| **MText to Attribute** | `MT2ATT` | Batch-converts MText objects into Attribute Definitions (`ATTDEF`) in-place. Fully compatible with **Block Editor (`BEDIT`)**, preserves styles, layers, colors, and justifications. | [`/LISP/MTEXT_TO_ATTR/`](./LISP/MTEXT_TO_ATTR/) |
| **Two-Way Live Sync** | `TWOWAYSYNC`, `TWOWAY1`, `SYNCALL`, `TWOWAYCLEAR` | **True Two-Way live synchronization** between matching numbers or tags across different sections (horizontal, vertical, diagonal). Edit either side $\rightarrow$ the other updates instantly. | [`/LISP/TWO_WAY_SYNC/`](./LISP/TWO_WAY_SYNC/) |
| **Dynamic Fields Linker** | `LINKBATCH`, `LINK1`, `COPYLINK` | One-way dynamic linking across sections using native AutoCAD DWG Fields (`%<\AcObjProp ...>%`). | [`/LISP/LINK_TEXT/`](./LISP/LINK_TEXT/) |
| **Selection Tools** | `SA`, `SR` | Fast selection and replacement of similar objects by layer, entity type, or block name. | [`/LISP/SELECTION/`](./LISP/SELECTION/) |
| **Visibility Management**| `HH`, `HR` | Temporarily isolate/hide and restore visibility of selected drawing elements. | [`/LISP/HIDE_SHOW/`](./LISP/HIDE_SHOW/) |

---

## 📁 Repository Structure

```
Tools-for-AutoCAD/
├── README.md                  ← Main repository documentation
└── LISP/
    ├── README.md              ← Comprehensive LISP catalog & loading guide
    ├── XLINE/                 ← Construction line shortcuts & multi-spacing arrays
    │   ├── XLINE_ALL.lsp
    │   └── README.md
    ├── MTEXT_TO_ATTR/         ← Convert MText to Attributes (BEDIT compatible)
    │   ├── MTEXT2ATTR.lsp
    │   └── README.md
    ├── TWO_WAY_SYNC/          ← Two-way live section tag synchronizer
    │   ├── TWO_WAY_SYNC.lsp
    │   └── README.md
    ├── LINK_TEXT/             ← Dynamic Field-based text linkers
    │   ├── LINK_TEXT.lsp
    │   └── README.md
    ├── SELECTION/             ← Selection helpers
    │   ├── Selection.lsp
    │   └── README.md
    ├── HIDE_SHOW/             ← Hide/restore visibility tools
    │   ├── HIDE_SHOW.LSP
    │   └── README.md
    └── Create Similar/        ← Create similar tools
        └── CREATE SIMILAR.LSP
```

---

## 🚀 How to Load & Use

### Method 1: APPLOAD (Recommended)
1. In AutoCAD, type `APPLOAD` and press **Enter**.
2. Navigate to the desired `.lsp` file inside the `LISP/` subfolders.
3. Click **Load**.
4. *(Optional)* Add the script to your **Startup Suite** (click the Briefcase icon in APPLOAD) to auto-load every time AutoCAD starts.

### Method 2: Command Line
Type:
```lisp
(load "path/to/script.lsp")
```

---

## 📝 Revision & Changelog

### Version 2.1 (Current Revision)
- **`XVN` & `XHN` Overhaul**: Fixed vertical construction line generation using native `_XLINE _V` mode. Added cursor-direction detection (left/right for vertical, up/down for horizontal) and spacing input via distance or snap points.
- **`TWO_WAY_SYNC` Multi-Attribute Support**: Added intelligent tag detection for blocks with multiple attributes (e.g. `NUM`, `TAG`, `PREFIX`). Auto-detects number attributes or prompts for the exact attribute tag.
- **`MTEXT2ATTR` In-Place Conversion**: Built custom block definition detection (`assoc 330`) so attribute conversion works seamlessly inside **Block Editor (`BEDIT`)** as well as Model and Paper Space. Automatically cleans invalid characters and names tags from text.
- **`LINK_TEXT` Coordinate Fix**: Fixed batch point coordinate accessors (`lt:item-x`, `lt:item-y`) ensuring robust sorting across arbitrary screen coordinates.
- **Cross-Platform Path Cleanup**: Cleaned up Windows folder naming conflicts and organized all scripts into dedicated, self-documenting directories.

---

## 🤝 Contributions & License

Contributions, feedback, and issue reports are welcome! Built for engineers, architects, drafters, and CAD professionals worldwide.
