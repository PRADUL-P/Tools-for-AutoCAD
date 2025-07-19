# 🔒 Hide_Show AutoCAD LISP Tool

This LISP script provides quick and efficient visibility control within AutoCAD using custom commands to **hide**, **isolate**, and **restore** objects.

---

## 📌 Features

- 🔹 **HH** – Hide selected objects from view.
- 🔹 **IL** – Isolate selected objects, hiding all others.
- 🔹 **HR** – Restore visibility of all previously hidden or isolated objects.

---

## 🛠 Commands Overview

| Command | Action                              | AutoCAD Equivalent                      |
|---------|-------------------------------------|------------------------------------------|
| `HH`    | Hide selected objects               | Right-click → Isolate → **Hide Objects** |
| `IL`    | Isolate selected objects            | Right-click → Isolate → **Isolate Objects** |
| `HR`    | Restore all object visibility       | Right-click → Isolate → **End Object Isolation** |

---

## ✅ Usage Instructions

1. **Load the LISP file** in AutoCAD using the `APPLOAD` command.
2. Run any of the following commands in the command line:
   - `HH` – Select objects to hide.
   - `IL` – Select objects to isolate.
   - `HR` – Unhide all hidden or isolated objects.
