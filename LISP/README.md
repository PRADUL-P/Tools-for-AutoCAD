# 🛠️ AutoCAD LISP Tools Catalog

Welcome to the **Tools-for-AutoCAD** LISP catalog! This directory contains specialized AutoLISP utilities designed to automate drafting, improve precision, and eliminate repetitive tasks in AutoCAD.

---

## 📂 Tool Directories & Documentation

Each toolset is placed in its own dedicated folder with standalone documentation:

| Folder | Core Commands | Documentation | Description |
|---|---|---|---|
| **[`/XLINE/`](./XLINE/)** | `XVN`, `XHN`, `XH`, `XV`, `XA`, `XB`, `XO` | [Read Docs](./XLINE/README.md) | Multi-spaced construction lines with mouse-direction detection and fast shortcuts. |
| **[`/MTEXT_TO_ATTR/`](./MTEXT_TO_ATTR/)** | `MT2ATT` | [Read Docs](./MTEXT_TO_ATTR/README.md) | In-place conversion of MText to Attribute Definitions (`ATTDEF`), Block Editor (`BEDIT`) ready. |
| **[`/TWO_WAY_SYNC/`](./TWO_WAY_SYNC/)** | `TWOWAYSYNC`, `TWOWAY1`, `SYNCALL` | [Read Docs](./TWO_WAY_SYNC/README.md) | True Two-Way live synchronization for section numbers across different views/shapes. |
| **[`/LINK_TEXT/`](./LINK_TEXT/)** | `LINKBATCH`, `LINK1`, `COPYLINK` | [Read Docs](./LINK_TEXT/README.md) | Native AutoCAD Field-based dynamic linking between sections. |
| **[`/SELECTION/`](./SELECTION/)** | `SA`, `SR` | [Read Docs](./SELECTION/README.md) | Selection filters by layer, entity type, and block definition. |
| **[`/HIDE_SHOW/`](./HIDE_SHOW/)** | `HH`, `HR` | [Read Docs](./HIDE_SHOW/README.md) | Temporary isolation and visibility restoration of drawing objects. |

---

## 🚀 How to Load Scripts in AutoCAD

1. Launch AutoCAD.
2. Type `APPLOAD` in the command bar and press `Enter`.
3. Browse to the `.lsp` file inside the corresponding subfolder.
4. Click **Load**.
5. Type the command name (e.g. `XVN`, `MT2ATT`, `TWOWAYSYNC`, etc.) in the command prompt.

### Auto-Load on Startup:
To have your favorite tools available in every drawing automatically:
1. Type `APPLOAD`.
2. Under **Startup Suite**, click the **Contents** button (briefcase icon).
3. Click **Add...** and choose your `.lsp` files.

---

## 📌 Troubleshooting Quick Guide

| Issue | Cause | Solution |
|---|---|---|
| `Unknown command "XYZ"` | The script has not been loaded in the current AutoCAD session. | Run `APPLOAD` and load the `.lsp` file first. |
| `Bad DXF group` | Attempting to pass non-primitive types to DXF functions. | All tools in this repo have been hardened with type-safe fallbacks. Ensure you are running the latest revision. |
| `Object is open for write` | Reactor attempted to write during an active transaction. | `TWO_WAY_SYNC` uses a deferred command-ended queue to prevent write-lock collisions. |
