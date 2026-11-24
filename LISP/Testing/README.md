# 🧪 Testing & Beta Tools

This directory contains tools currently under **active evaluation, development, and personal testing** by the author.

Once thoroughly tested and validated in real CAD drafting workflows, tools graduate from here into the [`/LISP/Published/`](../Published/) directory.

---

## 🔬 Current Tools Under Testing

| Toolset | Commands | Description | Folder |
|---|---|---|---|
| **Auto-Dimensioning** | `ADIM`, `AUTODIM`, `AD` | Multi-mode auto-dimensioning suite: Bounding Box (overall W/H), Segments (each edge), and Chain (continuous grid). | [`./AUTODIM/`](./AUTODIM/) |

---

## 📥 How to Test
Load the `.lsp` file directly into AutoCAD:
```lisp
(load "E:/AUTOCAD/Tools-for-AutoCAD/LISP/Testing/AUTODIM/AUTODIM.lsp")
```
Run `ADIM` or `AUTODIM` and verify functionality.
