# Cornix Split Keyboard — Layout Reference
*File: `conix_mlue_layout_v3.vil`*

A column-staggered split keyboard with two rotary encoders (one per half) and four thumb keys per half. Ten layers exist in the firmware, but only **five are reachable** (Layer 0 plus four momentary overlays). Layers 5–9 have no activation key and are currently unused.

---

## 1. Physical key legend

To keep the tables below readable, each physical key is referred to by the letter printed on its keycap (its Layer‑0 function), grouped by row.

**Left half**

| Row | Col 0 | Col 1 | Col 2 | Col 3 | Col 4 | Col 5 | Col 6 |
|---|---|---|---|---|---|---|---|
| Top | Esc | Q | W | E | R | T | — |
| Home | Ctrl | A | S | D | F | G | — |
| Bottom | Shift | Z | X | C | V | B | Encoder‑click |
| Outer/Thumb | Caps | Win | Alt | Red‑dot | Lower | Space | — |

**Right half**

| Row | Col 0 | Col 1 | Col 2 | Col 3 | Col 4 | Col 5 | Col 6 |
|---|---|---|---|---|---|---|---|
| Top | Bksp | P | O | I | U | Y | — |
| Home | Enter | \ | L | K | J | H | Encoder‑click |
| Bottom | / | Up | . | , | M | N | — |
| Outer/Thumb | Right | Down | Left | Green‑dot | Raise | Space | — |

> **v3 update:** the dual-role GUI/Space key moved sides — it's now the **right** thumb Space (tap = Space, hold = Left GUI), while the **left** thumb Space is plain Space. (Previously it was the other way around.)

---

## 2. Modifier keys — what they do at rest (Layer 0)

| Key | Modifier sent | Notes |
|---|---|---|
| **Ctrl** | Left Ctrl | Standard held modifier |
| **Shift** | Left Shift | Standard held modifier |
| **Caps** | Caps Lock | Toggles caps, not held |
| **Win** | Left GUI (Super) | The Hyprland/Omarchy "Super" key |
| **Alt** | Left Alt | Standard held modifier |
| **Space (right thumb)** | `LGUI_T(KC_SPACE)` | **Dual-role key**: tap = Space, hold = Left GUI. |
| **Space (left thumb)** | Plain Space | No dual role — this one is always just Space |

There is **no Right Shift, Right Ctrl, Right Alt, or Right GUI** anywhere on this board — every modifier is left-side only. (This matters for OS-level shortcuts like language-layout toggles, which is why this build uses `Alt+Shift` rather than `Shift+Shift`.)

---

## 3. Layer-switch keys — the four "portals"

| Key | Keycode | Layer opened | While held, gives you… |
|---|---|---|---|
| **Red-dot** (left, below Shift col) | `MO(1)` | Layer 1 | Symbols & punctuation |
| **Lower** (left thumb) | `MO(3)` | Layer 3 | Window resize / move-to-workspace |
| **Green-dot** (right, below Up col) | `MO(2)` | Layer 2 | Workspace switching & window focus |
| **Raise** (right thumb) | `MO(4)` | Layer 4 | System controls, F-keys, app launchers |

All four are *momentary* — the overlay is only active while the key is physically held down, and releasing it returns you to Layer 0 instantly.

---

## 4. Layer 0 — Base (always on)

Standard QWERTY typing layer.

| Key | Function |
|---|---|
| Esc | Escape |
| Q W E R T | Letters |
| Ctrl | Left Ctrl |
| A S D F G | Letters |
| Shift | Left Shift |
| Z X C V B | Letters |
| Encoder-click (left) | Mute |
| Caps | Caps Lock |
| Win | Left GUI |
| Alt | Left Alt |
| Red-dot | Hold → Layer 1 |
| Lower | Hold → Layer 3 |
| Space (left thumb) | Space |
| Bksp | Backspace |
| P O I U Y | Letters |
| Enter | Enter |
| \ | Backslash |
| L K J H | Letters |
| Encoder-click (right) | Mute (`KC_BTN3` slot — see note below) |
| / | Slash |
| Up | Up arrow |
| . , | Period, comma |
| M N | Letters |
| Right, Down, Left | Arrow keys |
| Green-dot | Hold → Layer 2 |
| Raise | Hold → Layer 4 |
| Space (right thumb) | `LGUI_T(KC_SPACE)` — tap = Space, hold = Left GUI |

> **Note:** the right encoder's click position is bound to `KC_BTN3` (mouse middle-click) on this layer rather than Mute — the two encoders are not symmetric here.

**Encoders (both halves, all layers):** rotate = Volume Down / Volume Up. No per-layer variation is currently configured — all 10 encoder-layout slots are identical.

---

## 5. Layer 1 — Symbols (hold Red-dot)

Numbers, punctuation, and shifted symbols for coding.

| Key | Function |
|---|---|
| Esc | Tab |
| Q W E R T | 1 2 3 4 5 |
| Ctrl | `` ` `` (grave) |
| A | `[` |
| S | `]` |
| D | `_` (underscore) |
| F | `;` |
| G | `-` |
| Shift | *(inactive)* |
| Z X C V B | `!` `@` `#` `$` `%` (shifted 1–5, column-aligned under the number row) |
| Encoder-click (left) | Mute |
| Caps, Win, Alt, Red-dot, Lower, Space (left thumb) | *(inactive — deliberately blank to avoid clashing with the layer-switch keys underneath)* |
| Bksp | Delete |
| P O I U Y | 0 9 8 7 6 |
| Enter | *(inactive)* |
| \ | `\|` (pipe) |
| L | `{` |
| K | `}` |
| J | `'` (quote) |
| H | `=` |
| Encoder-click (right) | *(inactive)* |
| / | `~` (tilde) |
| Up | `)` |
| . | `(` |
| , | `*` |
| M | `&` |
| N | `^` |
| Right, Down, Left, Green-dot, Raise, Space (right thumb) | *(inactive)* |

Design note: the shifted-number symbols are laid out so that the shifted version of a number sits two rows directly below the number itself — `!@#$%` under `1‑5`, and `~)(*&^` under `6‑0`.

---

## 6. Layer 2 — Workspace & Window Focus (hold Green-dot)

Omarchy/Hyprland workspace and focus shortcuts.

| Key | Function | Hyprland action |
|---|---|---|
| Esc | `Super+Tab` | Jump to next workspace |
| Q W E R T | `Super+1..5` | Jump to workspace 1–5 |
| Ctrl | `USER00` | Custom firmware-defined key — see §9 |
| A S D F G | *(inactive)* | |
| Encoder-click (left) | Mute | |
| Caps, Win, Alt, Red-dot, Lower, Space (left thumb) | *(inactive)* | |
| Bksp | Print Screen | Screenshot |
| P O I U Y | `Super+0/9/8/7/6` | Jump to workspace 6–10 |
| L | `Super+L` | Move focus (vim-style) |
| K | `Super+K` | Move focus |
| J | `Super+J` | Move focus |
| H | `Super+H` | Move focus |
| Encoder-click (right) | Mouse button 3 | |
| Right, Down, Left, Green-dot, Raise, Space (right thumb) | *(inactive)* | |

> ⚠️ The `Super+H/J/K/L` focus-movement bindings only work if you've unbound Omarchy's defaults for `Super+J` (toggle split) and `Super+K` (keybindings menu) in `~/.config/hypr/bindings.conf`.

---

## 7. Layer 3 — Resize & Move-to-Workspace (hold Lower)

| Key | Function | Hyprland action |
|---|---|---|
| Esc | `Super+Alt+L` *(decoded from raw `0xc0f`)* | Not in Omarchy's documented defaults — likely a personal binding; verify what it does on your system |
| Q W E R T | `Super+Shift+1..5` | Move active window to workspace 1–5 |
| Ctrl | `USER00` | Custom firmware-defined key — see §9 |
| Shift | `USER01` | Custom firmware-defined key — see §9 |
| Caps | `USER02` | Custom firmware-defined key — see §9 |
| G | `Super+Minus` | Expand window left |
| B | `Super+Shift+Equal` | Expand window down |
| Encoder-click (left) | Mute | |
| Win, Alt, Red-dot, Lower, Space (left thumb) | *(inactive)* | |
| P O I U Y | `Super+Shift+0/9/8/7/6` | Move window to workspace 6–10 |
| H | `Super+Equal` | Shrink window left |
| N | `Super+Shift+Minus` | Shrink window up |
| Encoder-click (right) | Mouse button 3 | |
| Everything else | *(inactive)* | |

---

## 8. Layer 4 — System (hold Raise)

| Key | Function |
|---|---|
| Esc→T row | F1, F2, F3, F4, F5, F6 |
| Ctrl | `Super+Ctrl+A` — Audio panel |
| A | `Super+Ctrl+B` — Bluetooth panel |
| S | `Super+Ctrl+W` — Wifi panel |
| D | `Super+Ctrl+D` — Display panel |
| F | `Super+Ctrl+P` — Power panel |
| G | `Super+Ctrl+L` — Lock computer |
| Shift | `Super+Escape` — System menu (suspend/restart) |
| Z | `Super+Ctrl+T` — Activity (btop) |
| X | `Super+Ctrl+C` — Capture menu |
| C | `Super+Ctrl+V` — Clipboard manager |
| V | `Super+Ctrl+E` — Emoji picker |
| B | `Super+Ctrl+Q` — Calculator |
| Encoder-click (left) | Mute |
| Caps, Win, Alt, Red-dot, Lower, Space (left thumb) | *(inactive)* |
| Bksp→Y row | F7, F8, F9, F10, F11, F12 |
| Enter | `Super+Return` — Terminal |
| \ | `Super+Alt+Return` *(decoded from raw `0xc28`)* — Tmux terminal |
| L | `Super+Shift+Return` — Browser |
| K | `Super+Shift+F` — File manager |
| J | `Super+Shift+N` — Neovim |
| H | `Super+Shift+D` — LazyDocker |
| Encoder-click (right) | Mouse button 3 |
| / | `Super+W` — Close window |
| Up | `Super+T` — Toggle floating |
| . | `Super+F` — Fullscreen |
| , | `Super+Shift+Space` — Toggle top bar |
| M | Print Screen — Screenshot |
| N | `Super+Print Screen` — Color picker |
| Right, Down, Left | *(inactive)* |
| Green-dot, Raise | *(layer-switch keys, always inactive on their own layer)* |
| Space (right thumb) | **M0 macro** — sends Alt+Shift chord to toggle US/Khmer keyboard layout |

---

## 9. Macros

| Slot | Steps | Purpose |
|---|---|---|
| **M0** | 1. Press Left Alt + Left Shift down together<br>2. Wait 100ms<br>3. Release both | Fires the OS-level `grp:alt_shift_toggle` shortcut to switch between English and Khmer input |

All other macro slots (M1–M31) are empty.

---

## 10. Things this file can't fully explain

- **`USER00`, `USER01`, `USER02`** — these are custom, firmware-defined keycodes (handled in your `keymap.c`'s `process_record_user()` function). What they actually *do* isn't stored in the `.vil` file itself — check your firmware source, or hold each one on the physical board and see what happens.
- **`Super+Alt+L`** (Layer 3, Esc key) — this decodes cleanly from the raw code stored in the file, but it isn't one of Omarchy's documented default shortcuts. It was already present before any of the changes made in this conversation, so it's worth testing to confirm what it currently does on your system.
- **Layers 5–9** exist in the firmware (32 macro slots are reserved and 10 layers are defined) but have no key bound to reach them — they're inert until you add a fifth `MO()`/`TG()` key somewhere.
