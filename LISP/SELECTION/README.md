# 🔧 AutoCAD Selection Tools – LISP Command Set

This AutoLISP file provides a set of powerful selection utilities to help you **quickly select similar objects** in your AutoCAD drawings. Use these tools to improve drafting speed and accuracy during modeling, editing, or cleanup.

---

## 📦 Included Commands

| Command | Shortcut | Description |
|---------|----------|-------------|
| **Select Same Type**          | `SA` / `SR` | Selects all objects of the same type (e.g., LINE, CIRCLE) as the selected object. |
| **Select Same Type & Layer** | `SAT`       | Selects all objects of the same type *and* on the same layer. |
| **Select Same Layer**        | `SAL`       | Selects all objects on the same layer as the selected object. |
| **Select Same Color**        | `SAC`       | Selects all objects that share the same color (by color number). |
| **Select All Objects**       | `SAA`       | Selects all visible objects in the entire drawing. |
| **Select Same Block Name**   | `SAB`       | Selects all instances of the same block name. |
| **Select Same Linetype**     | `SLT`       | Selects all objects that use the same linetype. |

---

## 🚀 How to Use

1. Load the `.lsp` file into AutoCAD using `APPLOAD`.
2. Type the shortcut command (e.g., `SA`, `SAT`, `SAC`).
3. Follow the prompts to select a reference object (where applicable).
4. All matching objects will be selected instantly.

---

## 🧪 Command Examples

### 🟦 `SA` or `SR` – Select Same Type  
**Example**: Select all CIRCLE objects in the drawing.  
**Steps**:  
1. Run `SA`  
2. Click on any circle  
3. All circles in the drawing will be selected

---

### 🟨 `SAT` – Select Same Type and Layer  
**Example**: Select all lines on the “GRID” layer.  
**Steps**:  
1. Run `SAT`  
2. Click on any LINE on the "GRID" layer  
3. Only lines on the "GRID" layer are selected

---

### 🟩 `SAL` – Select Same Layer  
**Example**: Select all objects on the “DOORS” layer.  
**Steps**:  
1. Run `SAL`  
2. Click on any object from the “DOORS” layer  
3. All objects (of any type) on that layer will be selected

---

### 🟥 `SAC` – Select Same Color  
**Example**: Select all red-colored elements (Color 1).  
**Steps**:  
1. Run `SAC`  
2. Click on any red object  
3. All objects with color 1 (red) will be selected

---

### ⚪ `SAA` – Select All Objects  
**Example**: Select everything in the current drawing space.  
**Steps**:  
1. Run `SAA`  
2. All objects will be selected — no need to click anything

---

### 🔲 `SAB` – Select Same Block  
**Example**: Select all instances of the block “DOOR01”.  
**Steps**:  
1. Run `SAB`  
2. Click on any DOOR01 block  
3. All DOOR01 blocks will be selected

---

### ⚫ `SLT` – Select Same Linetype  
**Example**: Select all elements with “CENTER” linetype.  
**Steps**:  
1. Run `SLT`  
2. Click on any object with “CENTER” linetype  
3. All objects using the same linetype will be selected

---





