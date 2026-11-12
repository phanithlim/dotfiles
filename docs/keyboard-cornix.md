# Cornix LP

Hold a thumb key to switch layer. Layer 2 and 3 are Hyprland, layer 4 is apps.

| Hold | Layer | For |
|---|---|---|
| — | 0 | Typing |
| `L5` thumb | 1 | Numbers, symbols, arrows on H/J/K/L |
| `R3` thumb | 2 | Workspaces, focus, swap |
| `L4` thumb | 3 | Send window, one-shot mods, resize |
| `R2` thumb | 4 | Apps, Harpoon on A/S/D/F |

Not in the tables: `Ctrl+B` then `U`/`I` previous/next herdr space, `A` next agent, `D`/`V` split, `R` resize.

### Layer 0
| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Esc | Q | W | E | R | T | | Y | U | I | O | P | Bksp |
| Alt | A | S | D | F | G | | H | J | K | L | ; | Enter |
| Shift | Z | X | C | V | B | | N | M | , | . | ↑ | //Shift |
| Tab | Super | Alt | **L3** | **L1** | Space/Super | | Space/Ctrl | **L4** | **L2** | ← | ↓ | → |

### Layer 1

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Tab | 1 | 2 | 3 | 4 | 5 | | 6 | 7 | 8 | 9 | 0 | Bksp |
| ` | _ | - | = | + | * | | ← | ↓ | ↑ | → | : | " |
| ▽ | @ | \| | & | ! | # | | ( | ) | { | } | [ | ] |
| Caps Word | · | · | · | · | · | | `->` | ' | \ | · | · | Del |

### Layer 2

| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Super+Tab | Super+1 | Super+2 | Super+3 | Super+4 | Super+5 | | Super+6 | Super+7 | Super+8 | Super+9 | Super+0 | Print |
| User 00 | · | · | · | · | · | | Super+H | Super+J | Super+K | Super+L | · | Super+Enter |
| ▽ | · | · | · | · | · | | · | Super+M | · | · | · | Ctrl+Super+/ |
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
| Caps | Super+Alt+Space | · | · | · | · | | · | · | · | · | · | · |

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
| J + K | Esc |
| D + F | 1×Alt |

Switch language (English / Khmer): Super+I (Omarchy's input language switch).

`A/B` = tap A, hold B. `·` = empty, `▽` = same as layer 0, `1×` = one-shot modifier.

Load in Vial: File → Load saved layout → `keyboard/cornix/cornix.vil`, and save to the same name after a change (older layouts are in git history). In Vial, turn on Permissive Hold (QMK Settings → Tap-Hold) so fast Space+key still gives Ctrl. Edit these tables by hand after a change.
