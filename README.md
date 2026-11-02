# 🛠️ Tools for AutoCAD

> 🔧 **Tools for AutoCAD** is a curated collection of production-grade **AutoLISP scripts and automation tools** designed to supercharge your CAD workflow. Built with a focus on **efficiency, precision, and practical field use**, this repository enables engineers, architects, and drafters to eliminate repetitive tasks, automate complex drawings, and speed up project delivery.

> 🧠 Unlock **CAD automation directly within AutoCAD** — 100% native AutoLISP, zero third-party plugins required.

---

## 🏗️ Repository Architecture

Similar to professional BIM/Revit standards, tools are separated into **Published (Production)** and **Testing (Beta)** stages:

```
Tools-for-AutoCAD/
├── README.md
└── LISP/
    ├── README.md
    │
    ├── Published/                 ← Production-Ready Tools (Daily Drafting)
    │   ├── XLINE/                 ← Multi-spaced construction lines (XVN, XHN, XH, XV, etc.)
    │   ├── TCOUNT_PLUS/           ← Advanced directional renumbering (LR, RL, TB, BT, SEL)
    │   ├── MTEXT_TO_ATTR/         ← In-place MText to ATTDEF conversion (BEDIT ready)
    │   ├── SELECTION/             ← Fast object selection (SA, SR)
    │   ├── HIDE_SHOW/             ← Element isolation & visibility tools (HH, HR)
    │   └── Create Similar/        ← Quick creation of matching objects
    │
    └── Testing/                   ← Experimental / Active Development (Beta)
        ├── TWO_WAY_SYNC/          ← True Two-Way live section tag synchronizer
        └── LINK_TEXT/             ← Dynamic Field-based text linkers across sections
```

---

## 🟢 Published Tools (Production-Ready)

| Toolset | Commands | Description | Folder |
|---|---|---|---|
| **Construction Lines** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | Extended XLINE tools. Includes **arraying multiple vertical/horizontal construction lines** with custom spacing and cursor-direction detection. | [`/Published/XLINE/`](./LISP/Published/XLINE/) |
| **Directional Renumbering** | `TC`, `TCOUNTPLUS` | Enhanced replacement for Express Tool `TCOUNT`. Renumber text/attributes in **any direction** (`LR`, `RL`, `TB`, `BT`, `SEL`), with simultaneous prefix, suffix, and leading zero padding. | [`/Published/TCOUNT_PLUS/`](./LISP/Published/TCOUNT_PLUS/) |
| **MText to Attribute** | `MT2ATT` | Batch-converts MText objects into Attribute Definitions (`ATTDEF`) in-place. Fully compatible with **Block Editor (`BEDIT`)**, preserves styles, layers, colors, and justifications. | [`/Published/MTEXT_TO_ATTR/`](./LISP/Published/MTEXT_TO_ATTR/) |
| **Selection Tools** | `SA`, `SR` | Fast selection and replacement of similar objects by layer, entity type, or block name. | [`/Published/SELECTION/`](./LISP/Published/SELECTION/) |
| **Visibility Management**| `HH`, `HR` | Temporarily isolate/hide and restore visibility of selected drawing elements. | [`/Published/HIDE_SHOW/`](./LISP/Published/HIDE_SHOW/) |
| **Create Similar** | Property matching | Quickly spawn new entities matching existing element properties. | [`/Published/Create Similar/`](./LISP/Published/Create%20Similar/) |

---

## 🟡 Testing Tools (Experimental / Beta)

| Toolset | Commands | Status | Description | Folder |
|---|---|---|---|---|
| **Two-Way Live Sync** | `TWOWAYSYNC`, `TWOWAY1`, `SYNCALL` | **Beta** | Live bidirectional synchronization between matching numbers/tags across sections using AutoLISP Object Reactors. | [`/Testing/TWO_WAY_SYNC/`](./LISP/Testing/TWO_WAY_SYNC/) |
| **Dynamic Fields Linker** | `LINKBATCH`, `LINK1`, `COPYLINK` | **Beta** | One-way dynamic linking across sections using native AutoCAD DWG Fields (`%<\AcObjProp ...>%`). | [`/Testing/LINK_TEXT/`](./LISP/Testing/LINK_TEXT/) |

---

## 🚀 How to Load & Use

### Method 1: APPLOAD (Recommended)
1. In AutoCAD, type `APPLOAD` and press **Enter**.
2. Navigate to the desired `.lsp` file inside the `LISP/Published/` subfolders.
3. Click **Load**.
4. *(Optional)* Add the script to your **Startup Suite** (briefcase icon) to auto-load every time AutoCAD starts.

### Method 2: Command Line
```lisp
(load "path/to/script.lsp")
```

---

## 📝 Revision & Changelog

### Version 2.2
- **Two-Tier Architecture**: Reorganized toolset into **`Published/`** (production-ready) and **`Testing/`** (beta/experimental) directories.
- **Published Release of `XVN` & `XHN`**: Verified vertical/horizontal multi-line arrays with cursor direction input.
- **Published Release of `MT2ATT`**: Verified in-place attribute creation working seamlessly inside Block Editor (`BEDIT`).
- **Testing Migration**: Relocated `TWO_WAY_SYNC` and `LINK_TEXT` into `Testing/` for continued field refinement on complex multi-attribute blocks.

---

## 🤝 Contributions & License

Contributions, feedback, and issue reports are welcome! Built for engineers, architects, drafters, and CAD professionals worldwide.
