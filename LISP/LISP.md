# 🛠️ AutoCAD LISP Tools

Welcome to the **Tools-for-AutoCAD** repository! This folder contains a collection of powerful and practical AutoLISP utilities designed to improve your productivity and simplify repetitive tasks in AutoCAD.

---

## 📁 Folder Structure

```
Tools-for-AutoCAD/
└── LISP/
    ├── README.md  ← You are here
    ├── SELECTION/         ← Select similar, by layer, color, block, etc.
    ├── XLINE/             ← Create multiple xlines, custom angles
    ├── HIDE_SHOW/         ← Temporarily hide/show selected objects
    └── ...                ← Future tools/extensions
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

## 📂 Explore Specific Tools

Each toolset has its own README for detailed usage instructions:

* 🔹 [Selection Tools](./SELECTION/) – Select objects by type, color, layer, etc.
* 🔹 [XLine Tools](./XLINE/) – Create xlines at various angles and positions
* 🔹 [Hide/Show Tools](./HIDE_SHOW/) – Temporarily hide or restore selected objects

> 🔗 Click any link above to view the full documentation and list of commands in that category.




## 🤝 Contributions

Feel free to fork, use, and contribute! Bug fixes, new tools, and improvements are welcome.

---

Happy Drafting! ✍️
