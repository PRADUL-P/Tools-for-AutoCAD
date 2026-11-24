# 🛠️ AutoCAD LISP Directory

Welcome to the **Tools-for-AutoCAD** LISP catalog! All scripts here are **100% verified, field-tested, and production-ready** for daily drafting in AutoCAD.

---

## 📁 Repository Structure

```
LISP/
├── README.md                  ← You are here
└── Published/                 ← Production-Ready Tools (Tested & Verified)
    ├── README.md
    ├── XLINE/                 ← Multi-spaced construction lines & shortcuts (XVN, XHN, etc.)
    ├── TCOUNT_PLUS/           ← Advanced directional renumbering tool (TC, TCOUNTPLUS)
    ├── ATTFIX/                ← Instant Attribute Value, Tag & Prompt synchronizer (AF, ATTFIX)
    ├── AUTODIM/               ← Smart Auto-Dimensioning suite (ADIM, AUTODIM, AD)
    ├── BLOCK_RENAMER/         ← Fast on-screen & batch block renamer (BRN, BNAME)
    ├── MTEXT_TO_ATTR/         ← In-place Text/MText to ATTDEF conversion (M2A, MT2ATT)
    ├── SELECTION/             ← Selection helpers (SA, SAT, SAL, SAC, etc.)
    ├── HIDE_SHOW/             ← Hide/isolate/restore visibility tools (HH, IL, HR)
    └── Create Similar/        ← Create matching elements (CS)
```

---

## 🟢 Published & Tested Tools Index

All tools below are located in [`/Published/`](./Published/) and ready for daily production:

| Toolset | Core Commands | Description | Documentation |
|---|---|---|---|
| **[XLINE](./Published/XLINE/)** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | Multi-spaced construction lines with cursor direction detection, fast axis shortcuts. | [View Details](./Published/XLINE/README.md) |
| **[TCOUNT_PLUS](./Published/TCOUNT_PLUS/)** | `TC`, `TCOUNTPLUS` | Advanced directional renumbering tool (LR, RL, TB, BT, Selection order) with prefix, suffix & leading zeros. | [View Details](./Published/TCOUNT_PLUS/README.md) |
| **[ATTFIX](./Published/ATTFIX/)** | `ATTFIX`, `AF` | Batch attribute synchronizer: Instantly updates Tag & Prompt based on Value (supports pre/post selection). | [View Details](./Published/ATTFIX/README.md) |
| **[AUTODIM](./Published/AUTODIM/)** | `ADIM`, `AUTODIM`, `AD` | Smart Auto-Dimensioning suite: Bounding Box (overall W/H), Segments (each edge), and Chain (continuous grid). | [View Details](./Published/AUTODIM/README.md) |
| **[BLOCK_RENAMER](./Published/BLOCK_RENAMER/)** | `BRN`, `BNAME`, `BLOCKRENAME` | Fast block renamer: Click-to-rename on screen, dynamic block safe, batch Find & Replace, Prefix & Suffix. | [View Details](./Published/BLOCK_RENAMER/README.md) |
| **[MTEXT_TO_ATTR](./Published/MTEXT_TO_ATTR/)** | `MT2ATT`, `M2A`, `T2A` | Batch-converts Text and MText objects into Attribute Definitions (`ATTDEF`) in-place. Works inside **Block Editor (`BEDIT`)**. | [View Details](./Published/MTEXT_TO_ATTR/README.md) |
| **[SELECTION](./Published/SELECTION/)** | `SA`, `SAT`, `SAL`, `SAC`, `SAB`, `SLT`, `SAA` | High-speed selection of similar objects by layer, entity type, color, or block definition. | [View Details](./Published/SELECTION/README.md) |
| **[HIDE_SHOW](./Published/HIDE_SHOW/)** | `HH`, `IL`, `HR` | Temporarily isolate/hide and restore drawing elements for clutter-free drafting. | [View Details](./Published/HIDE_SHOW/README.md) |
| **[Create Similar](./Published/Create%20Similar/)** | `CS` | Create matching elements based on selected entity properties. | [View Details](./Published/Create%20Similar/) |

---

## 🔮 Upcoming Features (Roadmap)

The following advanced tools are currently in research and development and will be published once tested and verified:

* **Two-Way Live Section Tag Synchronizer (`TWO_WAY_SYNC`)**:  
  Bidirectional real-time live synchronization between matching callout/section tags across drawings and viewports using AutoLISP Object Reactors.

* **Dynamic Field-Based Section Linker (`LINK_TEXT`)**:  
  Automated text-linking using native AutoCAD Field codes (`%<\AcObjProp ...>%`) across horizontal, vertical, and detail sections.

---

## 📥 How to Load
1. Use AutoCAD's `APPLOAD` command, select the `.lsp` file from any of the subfolders in `/Published/`, and click **Load**.
2. To keep them loaded permanently, add them to your **Startup Suite** (briefcase icon in APPLOAD).
