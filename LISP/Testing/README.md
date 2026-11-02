# 🧪 Testing & Experimental LISP Tools

This folder contains cutting-edge automation tools currently in the **active testing, development, and evaluation phase**.

> ⚠️ **Note**: Tools in this directory are undergoing field trials and refinements across various complex block types, anonymous blocks, and CAD standards. Once fully validated, they will graduate into the `/LISP/Published/` folder.

---

## 🔬 Experimental Tools Index

| Toolset | Commands | Current Status | Description | Documentation |
|---|---|---|---|---|
| **[TWO_WAY_SYNC](./TWO_WAY_SYNC/)** | `TWOWAYSYNC`, `TWOWAY1`, `SYNCALL`, `TWOWAYCLEAR` | **Beta / Field Testing** | Real-time bidirectional live synchronization between matching numbers/tags across sections using AutoLISP Object Reactors. | [View Details](./TWO_WAY_SYNC/README.md) |
| **[LINK_TEXT](./LINK_TEXT/)** | `LINKBATCH`, `LINK1`, `COPYLINK` | **Beta / Field Testing** | Dynamic Field-based text linking (`%<\AcObjProp ...>%`) between horizontal and vertical/diagonal sections. | [View Details](./LINK_TEXT/README.md) |

---

## 🛠️ Testing Objectives
- Handling non-standard, dynamic, and multi-attribute block references.
- Validating cross-file and viewport coordinate consistency.
- Testing persistence across diverse AutoCAD versions and third-party vertical applications (Civil 3D, MEP, Architecture).
