# 🚀 Published (Production-Ready) LISP Tools

This folder contains verified, production-grade AutoLISP tools that have been thoroughly tested for daily drafting workflows in AutoCAD.

---

## 📋 Published Tools Index

| Toolset | Core Commands | Description | Documentation |
|---|---|---|---|
| **[XLINE](./XLINE/)** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | Multi-spaced construction lines with cursor direction detection, fast axis shortcuts. | [View Details](./XLINE/README.md) |
| **[TCOUNT_PLUS](./TCOUNT_PLUS/)** | `TC`, `TCOUNTPLUS` | Advanced directional renumbering tool (Left/Right/Top/Bottom/Pick-order) with prefix, suffix & padding. | [View Details](./TCOUNT_PLUS/README.md) |
| **[ATTFIX](./ATTFIX/)** | `ATTFIX`, `AF` | Batch attribute synchronizer: Instantly updates Tag & Prompt based on Value (supports pre/post selection). | [View Details](./ATTFIX/README.md) |
| **[MTEXT_TO_ATTR](./MTEXT_TO_ATTR/)** | `MT2ATT`, `M2A`, `T2A` | Batch-converts Text and MText objects into Attribute Definitions (`ATTDEF`) in-place. Works inside the **Block Editor (`BEDIT`)**. | [View Details](./MTEXT_TO_ATTR/README.md) |
| **[SELECTION](./SELECTION/)** | `SA`, `SR` | High-speed selection of similar objects by layer, entity type, or block definition. | [View Details](./SELECTION/README.md) |
| **[HIDE_SHOW](./HIDE_SHOW/)** | `HH`, `HR` | Temporarily isolate/hide and restore drawing elements for clutter-free drafting. | [View Details](./HIDE_SHOW/README.md) |
| **[Create Similar](./Create%20Similar/)** | Fast creation shortcuts | Create matching elements based on selected entity properties. | [View Details](./Create%20Similar/) |

---

## 📥 How to Load
Use AutoCAD's `APPLOAD` command, select the `.lsp` file from any of the subfolders above, and click **Load**.
To keep them loaded permanently, add them to your **Startup Suite** (briefcase icon).
