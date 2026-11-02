# True Two-Way Live Synchronizer (`TWO_WAY_SYNC`)

A powerful AutoLISP tool that establishes a **True Two-Way (Bidirectional) Live Sync** between pairs of numbers or tags across different sections.

---

## ⚡ Why This Is Different From Standard Fields

| Feature | Standard AutoCAD Field | **TWO_WAY_SYNC** |
|---|---|---|
| **Direction** | One-Way only (Master $\rightarrow$ Follower) | **True Two-Way (EITHER can be edited)** |
| **Editing Horizontal** | Updates Vertical | **Updates Vertical instantly** |
| **Editing Vertical** | Breaks the link! ❌ | **Updates Horizontal instantly! ✅** |
| **Needs `REGEN`?** | Yes, must run `REGEN` | **No, updates in REAL-TIME immediately** |
| **Entities Supported** | Text, MText, Attributes | Text, MText, and Blocks with attributes |
| **Different Blocks?** | Yes | **Yes, works with completely different blocks!** |

---

## 🎯 How It Solves Your 1–11 Section Matching

In your drawing:
- Horizontal Section: `1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11`
- Vertical / Diagonal Section: `1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11`

### Smart Value Matching (Zero Sorting Errors!):
`TWOWAYSYNC` reads the existing number values:
- It automatically finds `1` in Section A and pairs it to `1` in Section B.
- It automatically finds `2` in Section A and pairs it to `2` in Section B.
- ...
- It automatically finds `11` in Section A and pairs it to `11` in Section B.

This means **you don't have to worry about spatial order, angles, or sorting mistakes**!

---

## 🚀 How to Use

1. Load the script:
   ```lisp
   (load "TWO_WAY_SYNC.lsp")
   ```
2. Type at the command prompt:
   ```text
   TWOWAYSYNC
   ```
3. **Prompt 1**: Window-select the 11 numbers in your horizontal section.
4. **Prompt 2**: Window-select the 11 numbers in your vertical section.
5. **Done!** All 11 pairs are now live-synced bidirectionally!

### Test it:
- Double-click number `5` in your horizontal section and change it to `5A` $\rightarrow$ the vertical section changes to `5A` immediately!
- Double-click number `10` in your vertical section and change it to `12` $\rightarrow$ the horizontal section changes to `12` immediately!

---

## 📋 All Commands

| Command | Description |
|---|---|
| **`TWOWAYSYNC`** | Batch pair two groups of numbers with smart value matching (1..11) |
| **`TWOWAY1`** | Pair two individual items click-by-click |
| **`SYNCALL`** | Scan and force-refresh all pairs across the drawing |
| **`TWOWAYCLEAR`** | Remove two-way sync from selected objects |
