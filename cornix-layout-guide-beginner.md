# My Cornix Keyboard — Simple Guide

This explains what every key on your keyboard does. No prior keyboard-firmware knowledge needed.

---

## The big idea: one keyboard, five "modes"

Your keyboard has **5 modes** (called "layers"). You're always in Mode 1 (the normal typing mode) unless you're **holding down** one of four special keys — the moment you let go, you're back to normal.

Think of it like a phone's Shift key, but bigger: instead of just capitalizing one letter, holding a different key can turn your *whole keyboard* into a number pad, a set of app shortcuts, or a system control panel.

| Hold this key... | ...and your keyboard becomes | Located |
|---|---|---|
| Nothing | **Normal typing** (Mode 1) | — |
| 🔴 Red dot | **Symbols** (Mode 2) | Left hand, thumb area |
| Lower | **Resize windows** (Mode 3) | Left hand, thumb area |
| 🟢 Green dot | **Switch workspaces** (Mode 4) | Right hand, thumb area |
| Raise | **System shortcuts** (Mode 5) | Right hand, thumb area |

That's the whole concept. Everything below just lists what each key does in each mode.

---

## Mode 1: Normal Typing

This is just a regular keyboard. Nothing surprising here — letters are letters, and:

- **Ctrl, Shift, Alt** work like on any keyboard
- **Win** = the Windows/Super key (used a lot in Linux)
- **Caps** = Caps Lock
- Arrow keys are in their own little cluster on the right
- **Right-hand thumb Space bar** is special: tap it for a normal space, but *hold* it down and it acts as the **Win/Super** key instead. This means you can trigger Super-key shortcuts with either hand.
- The left-hand thumb Space bar is just a normal space, nothing fancy.
- Both little dials (encoders) turn the volume up and down. Clicking the left one mutes; clicking the right one does a mouse middle-click.

---

## Mode 2: Symbols (hold the 🔴 Red dot)

Use this whenever you need a number or a symbol that isn't on the front of a key.

**Numbers:**
```
Top row:    1  2  3  4  5      6  7  8  9  0
```

**Common coding symbols**, roughly grouped by hand:

| You get | By pressing (while holding Red dot) |
|---|---|
| `` ` `` | (where Ctrl normally is) |
| `[` `]` | (where A, S normally are) |
| `_` | (where D normally is) |
| `;` `-` | (where F, G normally are) |
| `!  @  #  $  %` | (where Z X C V B normally are) |
| `\|` | (where \ normally is) |
| `{` `}` | (where L, K normally are) |
| `'` `=` | (where J, H normally are) |
| `~  )  (  *  &  ^` | (where / Up . , M N normally are) |

**Handy trick:** the shifted symbol always sits two rows below its number — so `!` (shift of `1`) is two rows under the `1` key, and so on. Once you notice this pattern it's easy to guess where a symbol is.

**Delete** replaces Backspace in this mode.

---

## Mode 3: Resize Windows (hold Lower)

For moving and resizing windows on your desktop (Hyprland/Omarchy shortcuts).

| Key | What it does |
|---|---|
| Q W E R T | Move the current window to workspace 1–5 |
| P O I U Y | Move the current window to workspace 6–10 |
| G | Make window bigger (expand left) |
| B | Make window bigger (expand down) |
| H | Make window smaller (shrink left) |
| N | Make window smaller (shrink up) |
| Esc | A custom shortcut — not something built into your desktop by default. Worth testing to remember what it does. |

Three keys (Ctrl, Shift, Caps) run **your own custom shortcuts** that were set up separately and aren't described in this keyboard file — if you forget what they do, just press one and see what happens.

---

## Mode 4: Switch Workspaces & Windows (hold the 🟢 Green dot)

For jumping between virtual desktops and switching which window is focused.

| Key | What it does |
|---|---|
| Esc | Go to the next workspace |
| Q W E R T | Jump straight to workspace 1–5 |
| P O I U Y | Jump straight to workspace 6–10 |
| Bksp | Take a screenshot |
| H J K L | Move focus to the window in that direction (like vim: H=left, J=down, K=up, L=right) |

> **Heads up:** for H/J/K/L to actually work this way, your desktop's own default shortcuts for those same keys need to be turned off first (they're normally used for something else in Omarchy). If it's not working, that's the likely reason.

Ctrl runs one more custom shortcut (same kind as Mode 3, defined elsewhere).

---

## Mode 5: System Shortcuts (hold Raise)

Your "everything else" panel — quick access to system settings, apps, and window controls.

**Function keys**, split across both hands:
```
Left hand:   F1  F2  F3  F4  F5  F6
Right hand:  F7  F8  F9  F10 F11 F12
```

**System panels** (left hand):

| Key | Opens |
|---|---|
| Ctrl | Audio settings |
| A | Bluetooth settings |
| S | Wifi settings |
| D | Display settings |
| F | Power settings |
| G | Lock your computer |
| Shift | System menu (restart, suspend, etc.) |
| Z | Activity monitor |
| X | Screenshot/recording menu |
| C | Clipboard history |
| V | Emoji picker |
| B | Calculator |

**Apps & window controls** (right hand):

| Key | Opens / does |
|---|---|
| Enter | Terminal |
| \ | Terminal with tmux |
| L | Web browser |
| K | File manager |
| J | Neovim (text editor) |
| H | Docker manager |
| / | Close the current window |
| Up | Make window floating |
| . | Fullscreen |
| , | Show/hide the top bar |
| M | Take a screenshot |
| N | Pick a color from the screen |
| **Space (right thumb)** | **Switch keyboard language** (see below) |

---

## The language switcher

That last key — the Space bar under your right thumb, pressed while holding Raise — doesn't type anything. Instead it presses **Alt + Shift** together for you, which tells your computer to flip between English and Khmer typing.

So to switch language: **hold Raise, tap the Space key next to it.** Tap the same combo again to switch back.

---

## Quick-reference cheat sheet

```
                Hold nothing → Normal typing
                Hold 🔴 Red dot → Symbols & numbers
                Hold Lower   → Resize / move windows
                Hold 🟢 Green dot → Switch workspaces & focus
                Hold Raise   → System settings, apps, language switch
```

If you only remember one thing: **every special function requires holding one of those four keys down first.** Nothing happens by accident — release the key and you're always back to plain typing.
