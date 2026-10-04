# Cornix LP keyboard

Load in Vial: **File → Load saved layout** → `keyboard/cornix/mycurrent-cornix.vil`

## Layers

| Hold | Layer | For |
|---|---|---|
| — | 0 | Typing |
| `L5` thumb | 1 | Numbers, symbols, arrows on H/J/K/L |
| `R3` thumb | 2 | Hyprland: workspaces, focus, swap (+ Shift) |
| `L4` thumb | 3 | Move window to workspace, one-shot mods, resize |
| `R2` thumb | 4 | Apps, menus, Harpoon on A/S/D/F, Caps Lock |

## Special keys

| Key | Does |
|---|---|
| L4 + A/S/D/F | Harpoon file 1–4 (Alt+1–4) |
| L4 + outer left thumb | Caps Lock |
| L4 + right inner thumb (Macro 0) | English ⇄ Khmer |
| L2 + M | Window laptop ⇄ external monitor |
| Combo A+B / S+B | Previous / next tmux window or Neovide tab |

### Layer 0

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Esc | Q | W | E | R | T | | Y | U | I | O | P | Bksp |
| Ctrl | A | S | D | F | G | | H | J | K | L | ; | Enter |
| Shift | Z | X | C | V | B | | N | M | , | . | ↑ | / |
| Esc | Super | Alt | **L3** | **L1** | Space/Super | | Space/Ctrl | **L4** | **L2** | ← | ↓ | → |

### Layer 1

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Tab | 1 | 2 | 3 | 4 | 5 | | 6 | 7 | 8 | 9 | 0 | Bksp |
| ` | [ | ] | ' | ; | - | | ← | ↓ | ↑ | → | \ | = |
| ▽ | · | · | · | · | · | | · | · | · | · | · | · |
| · | · | · | · | · | · | | · | · | · | · | · | Del |

### Layer 2

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Super+Tab | Super+1 | Super+2 | Super+3 | Super+4 | Super+5 | | Super+6 | Super+7 | Super+8 | Super+9 | Super+0 | Print |
| User 00 | · | · | · | · | · | | Super+H | Super+J | Super+K | Super+L | · | Super+Enter |
| ▽ | · | · | · | · | · | | · | Super+M | · | · | · | · |
| · | · | · | · | · | · | | · | · | · | · | · | · |

### Layer 3

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Super+Alt+L | Super+Shift+1 | Super+Shift+2 | Super+Shift+3 | Super+Shift+4 | Super+Shift+5 | | Super+Shift+6 | Super+Shift+7 | Super+Shift+8 | Super+Shift+9 | Super+Shift+0 | · |
| · | 1×Super | 1×Alt | 1×Ctrl | 1×Shift | Super+- | | Super+= | 1×Shift | 1×Ctrl | 1×Alt | 1×Super | · |
| · | · | · | · | · | Super+Shift+= | | Super+Shift+- | · | · | · | · | · |
| · | · | · | · | · | · | | · | · | · | User 00 | User 01 | User 02 |

### Layer 4

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| · | · | Super+W | · | · | · | | · | Super+N | Super+Alt+Enter | · | · | · |
| · | Alt+1 | Alt+2 | Alt+3 | Alt+4 | Ctrl+Super+L | | Super+Shift+D | Super+Shift+N | Super+Shift+F | Super+Shift+Enter | Super+Alt+Enter | Super+Enter |
| · | Ctrl+Super+T | · | Ctrl+Super+V | Ctrl+Super+E | · | | Super+Print | Print | Super+Shift+Space | Super+F | Super+T | Super+W |
| Caps | Super+Alt+Space | · | · | · | · | | Macro 0 | · | · | · | · | · |

### Knobs (turn left / right)

| Layer | Left knob | Right knob |
|---|---|---|
| 0 | Vol- / Vol+ | Wheel↑ / Wheel↓ |
| 1 | Vol- / Vol+ | Wheel↑ / Wheel↓ |
| 2 | Super+Shift+Tab / Super+Tab | Wheel↑ / Wheel↓ |
| 3 | Vol- / Vol+ | Wheel↑ / Wheel↓ |
| 4 | Ctrl+P / Ctrl+N | Wheel↑ / Wheel↓ |

### Combos

| Press together | Sends |
|---|---|
| A + B | Ctrl+B Ctrl+P |
| S + B | Ctrl+B Ctrl+N |

`·` = empty, `▽` = same as layer 0, `1×` = one-shot modifier.

Rebuild these tables after changing the layout:

```bash
python3 keyboard/cornix/vil2md.py keyboard/cornix/mycurrent-cornix.vil
```
