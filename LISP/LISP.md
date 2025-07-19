# 🛠️ AutoCAD LISP Tools

Welcome to the **Tools-for-AutoCAD** repository! This folder contains a collection of powerful and practical AutoLISP utilities designed to improve your productivity and simplify repetitive tasks in AutoCAD.

---

## 📁 Folder Structure

```
Tools-for-AutoCAD/
└── LISP/
    ├── README.md              ← You are here
    ├── selection-tools/        ← Select similar, by layer, color, block, etc.
    ├── xline-tools/            ← Create multiple xlines, custom angles
    ├── hide-show-tools/        ← Temporarily hide/show selected objects
    └── ...                     ← Future tools/extensions
```

---

## 🔍 About This Repository

This repository is created to provide a centralized place for handy LISP routines that:

* Automate common CAD workflows
* Help in faster object selection
* Improve drawing clarity
* Aid in repetitive design/drafting tasks

These tools are created by a practicing Civil Engineer for engineers, drafters, and CAD professionals.

---

## ✨ Advantages of Using AutoLISP Tools

✅ **Boost Efficiency**: Reduce repetitive manual selections and actions
✅ **Customization**: Easily editable and adaptable to your workflow
✅ **Simplicity**: Lightweight and written in clear, documented LISP
✅ **Compatibility**: Works with AutoCAD 2016 and above
✅ **Open-source**: Extend, fork, or contribute back

---

## 🚀 How to Load a LISP File in AutoCAD

1. Launch AutoCAD
2. Type `APPLOAD` in the command bar and press `Enter`
3. Browse to the `.lsp` file inside the `/LISP/` subfolders
4. Click **Load**
5. Use the defined command (e.g., `SA`, `HH`, `XL`, etc.) in the command bar

### Optional (Auto-Load at Startup):

* In the APPLOAD dialog, click **Contents** under Startup Suite
* Add your `.lsp` files here to load them automatically each time AutoCAD starts

---

## ❗ Common Issues & Fixes

| Problem                  | Cause                           | Solution                                |
| ------------------------ | ------------------------------- | --------------------------------------- |
| `Unknown command`        | LISP file not loaded            | Use `APPLOAD` before typing the command |
| `No function definition` | Syntax error or incomplete load | Reload or review the LISP file          |
| `Nothing selected`       | Empty or invalid selection      | Ensure you're selecting valid objects   |

---

## 📆 Included LISP Categories

Below are the currently available tools grouped by functionality:

### 🔹 Selection Tools ([View Folder](./selection-tools/))

* [`SA` / `SR`](./selection-tools/select-similar.lsp): Select all similar objects
* [`SAT`](./selection-tools/select-same-type-layer.lsp): Select same type on same layer
* [`SAL`](./selection-tools/select-same-layer.lsp): Select all objects on the same layer
* [`SAC`](./selection-tools/select-by-color.lsp): Select by color
* [`SAB`](./selection-tools/select-by-block.lsp): Select by block name
* [`SAA`](./selection-tools/select-all.lsp): Select all in drawing
* [`SLT`](./selection-tools/select-line-type.lsp): Select by line type

### 🔹 XLine Tools ([Browse](./xline-tools/))

* [`XL`](./xline-tools/xline-cross.lsp): Create cross xlines
* [`XH`](./xline-tools/xline-horizontal.lsp): Horizontal xline
* [`XV`](./xline-tools/xline-vertical.lsp): Vertical xline
* [`XA`](./xline-tools/xline-angle.lsp): Xlines at custom angles

### 🔹 Hide/Show Tools ([Browse](./hide-show-tools/))

* [`HH`](./hide-show-tools/hide-selected.lsp): Temporarily hide selected
* [`HR`](./hide-show-tools/restore-hidden.lsp): Restore all hidden objects

### 🔹 Coming Soon

* Delete filtered objects
* Batch renaming tools
* Object alignment utilities

---

## 🧪 Testing

All commands have been tested on:

* AutoCAD 2016, 2019, 2023
* Windows 10 & 11

---

## 📄 License

This repository is open-source and licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

## 🤝 Contributions

Feel free to fork, use, and contribute! Bug fixes, new tools, and improvements are welcome.

---

Happy Drafting! ✍️
