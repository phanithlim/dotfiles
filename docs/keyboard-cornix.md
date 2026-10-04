# Cornix LP keyboard layout

Layout file: [`keyboard/cornix/mycurrent-cornix.vil`](../keyboard/cornix/mycurrent-cornix.vil).
Load it in Vial with **File → Load saved layout**.

The tables below are generated from that file (see "Regenerating" at the end).
Each row reads left to right as the keys sit on the board: `L1` is the left
outer column, `R6` the right outer column. `·` means no key, `▽` means
"falls through to the layer below".

## How the layers fit together

| Hold | Layer | What it is for |
|---|---|---|
| — | 0 | Typing. Thumbs: Space/Super (left), Space/Ctrl (right) |
| Left thumb `L5` | 1 | Numbers, symbols, Vim-direction arrows on H/J/K/L |
| Right thumb `R3` | 2 | Hyprland: workspaces 1–0, focus window with H/J/K/L |
| Left thumb `L4` | 3 | Move window to workspace, one-shot modifiers, window resize |
| Right thumb `R2` | 4 | Apps and Omarchy menus, Harpoon files on A/S/D/F |

The same keys move focus at every level:

| Hold | + H / J / K / L |
|---|---|
| Layer 1 | Arrow keys |
| Right Space (Ctrl) | Neovim split / tmux pane (vim-tmux-navigator) |
| Layer 2 | Hyprland window |
| Layer 4 (A/S/D/F) | Harpoon file 1–4 in Neovim |

## Layers

### Layer 0

| L1 | L2 | L3 | L4 | L5 | L6 | ‖ | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Esc | Q | W | E | R | T | ‖ | Y | U | I | O | P | Bksp |
| Ctrl | A | S | D | F | G | ‖ | H | J | K | L | ; | Enter |
| Shift | Z | X | C | V | B | ‖ | N | M | , | . | ↑ | / |
| Esc | Super | Alt | **L3** (hold) | **L1** (hold) | Space / Super (hold) | ‖ | Space / Ctrl (hold) | **L4** (hold) | **L2** (hold) | ← | ↓ | → |

Knobs: left Vol- / Vol+, right Wheel↑ / Wheel↓ (counter-clockwise / clockwise)

### Layer 1

| L1 | L2 | L3 | L4 | L5 | L6 | ‖ | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Tab | 1 | 2 | 3 | 4 | 5 | ‖ | 6 | 7 | 8 | 9 | 0 | Bksp |
| ` | [ | ] | ' | ; | - | ‖ | ← | ↓ | ↑ | → | \ | = |
| ▽ | · | · | · | · | · | ‖ | · | · | · | · | · | · |
| · | · | · | · | · | · | ‖ | · | · | · | · | · | Del |

Knobs: left Vol- / Vol+, right Wheel↑ / Wheel↓ (counter-clockwise / clockwise)

### Layer 2

| L1 | L2 | L3 | L4 | L5 | L6 | ‖ | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Super+Tab | Super+1 | Super+2 | Super+3 | Super+4 | Super+5 | ‖ | Super+6 | Super+7 | Super+8 | Super+9 | Super+0 | Print |
| User 00 | · | · | · | · | · | ‖ | Super+H | Super+J | Super+K | Super+L | · | Super+Enter |
| · | · | · | · | · | · | ‖ | · | · | · | · | · | · |
| · | · | · | · | · | · | ‖ | · | · | · | · | · | · |

Knobs: left Super+Shift+Tab / Super+Tab, right Wheel↑ / Wheel↓ (counter-clockwise / clockwise)

### Layer 3

| L1 | L2 | L3 | L4 | L5 | L6 | ‖ | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Super+Alt+L | Super+Shift+1 | Super+Shift+2 | Super+Shift+3 | Super+Shift+4 | Super+Shift+5 | ‖ | Super+Shift+6 | Super+Shift+7 | Super+Shift+8 | Super+Shift+9 | Super+Shift+0 | · |
| · | One-shot Super | One-shot Alt | One-shot Ctrl | One-shot Shift | Super+- | ‖ | Super+= | One-shot Shift | One-shot Ctrl | One-shot Alt | One-shot Super | · |
| · | · | · | · | · | Super+Shift+= | ‖ | Super+Shift+- | · | · | · | · | · |
| · | · | · | · | · | · | ‖ | · | · | · | User 00 | User 01 | User 02 |

Knobs: left Vol- / Vol+, right Wheel↑ / Wheel↓ (counter-clockwise / clockwise)

### Layer 4

| L1 | L2 | L3 | L4 | L5 | L6 | ‖ | R1 | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| · | · | Super+W | · | · | · | ‖ | · | Super+N | Super+Alt+Enter | · | · | · |
| · | Alt+1 | Alt+2 | Alt+3 | Alt+4 | Ctrl+Super+L | ‖ | Super+Shift+D | Super+Shift+N | Super+Shift+F | Super+Shift+Enter | Super+Alt+Enter | Super+Enter |
| · | Ctrl+Super+T | · | Ctrl+Super+V | Ctrl+Super+E | · | ‖ | Super+Print | Print | Super+Shift+Space | Super+F | Super+T | Super+W |
| · | Super+Alt+Space | · | · | · | · | ‖ | Macro 0 | · | · | · | · | · |

Knobs: left Ctrl+P / Ctrl+N, right Wheel↑ / Wheel↓ (counter-clockwise / clockwise)

### Combos

- A + B → Macro 1
- S + B → Macro 2

### Macros

- Macro 0: down Alt+Shift wait 100ms up Alt+Shift
- Macro 1: down Ctrl tap B up Ctrl down Ctrl tap P up Ctrl
- Macro 2: down Ctrl tap B up Ctrl down Ctrl tap N up Ctrl

## Notes

- **Macro 0** (layer 4, right inner thumb) taps Alt+Shift, which switches the
  keyboard layout between English and Khmer (`grp:alt_shift_toggle` in
  `hypr/input.lua`).
- **Combos A+B / S+B** send `Ctrl-b Ctrl-p` / `Ctrl-b Ctrl-n`: previous/next
  window in tmux (bound in `tmux/tmux.conf`), previous/next tab in Neovide.
- **Layer 4 knob** sends Ctrl+P / Ctrl+N: previous/next Harpoon file in Neovim.
- **Layer 2 knob** cycles occupied workspaces (Super+Tab / Super+Shift+Tab).
- **Layer 4 + A/S/D/F** sends Alt+1–4, mapped to Harpoon files 1–4 in Neovim.
- Layer 4 has Super+Alt+Enter (Ghostty + tmux) twice, on I and on the right
  home row next to Enter.
- `User 00–02` are keyboard-side functions defined by the Cornix firmware.

## Regenerating these tables

The tables come from the `.vil` file. To rebuild them after changing the
layout, run:

```bash
python3 keyboard/cornix/vil2md.py keyboard/cornix/mycurrent-cornix.vil
```

and paste the output over the "Layers" section.
