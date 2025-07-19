# 📐 XLINE Construction Tools – AutoLISP for AutoCAD

This AutoLISP script enables **quick drafting of construction lines (XLINEs)** in multiple orientations—horizontal, vertical, angled, bisecting, or offset.  
It's designed to **boost drafting speed** by assigning direct shortcut commands to commonly used XLINE functions.

---

## 💡 Included Commands

| Command | Function           | Description                                                  |
|---------|--------------------|--------------------------------------------------------------|
| `XH`    | Horizontal XLINE   | Draws an infinite horizontal construction line               |
| `XV`    | Vertical XLINE     | Draws an infinite vertical construction line                 |
| `XA`    | Angled XLINE       | Prompts user to specify angle and base point                 |
| `XB`    | Bisecting XLINE    | Creates a line bisecting two selected objects (e.g. lines)   |
| `XO`    | Offset XLINE       | Draws an XLINE offset from an existing one by given distance |

---

## ⚙️ Shortcut Key Features

- 🧭 Instant drafting of **infinite construction lines**  
- 🧠 Shortcut-based design for **CAD power users**  
- ✨ Reduces the need to manually choose XLINE options each time  

---

## 🖥️ Usage Instructions

### 🧩 Step-by-Step: Load the LISP in AutoCAD

1. Open **AutoCAD**
2. Type `APPLOAD` in the command line and press `Enter`
3. Locate and select `XLINE.LSP`
4. Click **Load**

---

## ⌨️ How to Use

After loading, enter any of the following commands:

- 🔹 `XH` → Draw horizontal XLINE  
- 🔹 `XV` → Draw vertical XLINE  
- 🔹 `XA` → Specify angle → Draw XLINE  
- 🔹 `XB` → Select two lines → Draw bisector  
- 🔹 `XO` → Select XLINE → Specify offset distance  

Follow AutoCAD’s prompts as needed.

---

