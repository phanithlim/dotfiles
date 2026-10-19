import json, re, sys
import vil2md
from vil2md import name, typed

LAYERS = {1: ("NUM", "Numbers, symbols, arrows"), 2: ("NAV", "Workspaces and window focus"),
          3: ("WIN", "Move and resize windows"), 4: ("APP", "Apps and menus")}
THUMBS = {3: "left outer", 4: "left middle", 5: "left inner", 6: "right inner", 7: "right middle", 8: "right outer"}
ACTIONS = {"Super+Tab": "Next WS", "Print": "Screenshot", "Super+Print": "Color pick", "Super+Enter": "Terminal",
           "Super+H": "Focus ←", "Super+J": "Focus ↓", "Super+K": "Focus ↑", "Super+L": "Focus →",
           "Super+M": "Monitor ⇄", "Ctrl+Super+/": "Cheat sheet", "Super+Alt+L": "Layout ⇄",
           "Super+-": "Wider", "Super+=": "Narrower", "Super+Shift+=": "Taller", "Super+Shift+-": "Shorter",
           "Super+W": "Close", "Super+N": "Neovide", "Super+Alt+Enter": "Tmux", "Ctrl+Super+L": "Lock",
           "Super+Shift+D": "Docker", "Super+Shift+N": "Editor", "Super+Shift+F": "Files",
           "Super+Shift+Enter": "Browser", "Ctrl+Super+T": "Activity", "Ctrl+Super+V": "Clipboard",
           "Ctrl+Super+E": "Emoji", "Super+Shift+Space": "Top bar", "Super+F": "Fullscreen", "Super+T": "Float",
           "Super+Alt+Space": "Apps", "Macro 0": "EN ⇄ KH", "Caps": "Caps Lock", "▽": "",
           "Ctrl+P": "Prev", "Ctrl+N": "Next", "Super+Shift+Tab": "Prev WS"}
for n in range(10):
    ACTIONS[f"Super+{n}"] = f"WS {n or 10}"
    ACTIONS[f"Super+Shift+{n}"] = f"→ WS {n or 10}"
    ACTIONS[f"User 0{n}"] = f"BT {n}"
for n in range(1, 5): ACTIONS[f"Alt+{n}"] = f"Harpoon {n}"

def label(k):
    s = name(k)
    m = re.fullmatch(r"\*\*L(\d)\*\*", s)
    if m: return f"**{LAYERS[int(m[1])][0]}**"
    return ACTIONS.get(s, s).replace("|", "\\|")

def grid(layer):
    rows = [[label(x) for x in layer[r][:6]] + [""] + [label(x) for x in layer[r + 4][:6][::-1]] for r in range(4)]
    out = ["| Left | | | | | | | Right | | | | | |", "|" + "---|" * 13]
    out += ["| " + " | ".join(r) + " |" for r in rows if any(r)]
    return out

if __name__ == "__main__":
    d = json.load(open(sys.argv[1]))
    for i, m in enumerate(d["macro"]):
        t = typed(m) if m else None
        if t: vil2md.MACROS[f"M{i}"] = f"`{t}`"
    thumbs = {}
    for r in (3, 7):
        for c, k in enumerate(d["layout"][0][r][:6]):
            if isinstance(k, str) and k.startswith("MO("):
                thumbs[int(k[3])] = THUMBS[c if r == 3 else 11 - c]
    out = ["# Cornix cheat sheet", "", "Hold a thumb key to switch layer. Let go to type again.", "",
           "| Hold | Layer | For |", "|---|---|---|"]
    out += [f"| {thumbs[i]} thumb | **{n}** | {f} |" for i, (n, f) in LAYERS.items()]
    for i, (n, f) in LAYERS.items():
        out += ["", f"## {n} · {thumbs[i]} thumb", ""] + grid(d["layout"][i])
        if n == "NAV": out += ["", "Add **Shift** to Focus ←↓↑→ to swap windows."]
    out += ["", "## Knobs", "", "- Left: volume · Right: scroll"]
    for i, (n, _) in LAYERS.items():
        enc = d["encoder_layout"][i][0]
        if [name(x) for x in enc] != ["Vol-", "Vol+"]:
            out.append(f"- In **{n}**, left knob: {label(enc[0])} / {label(enc[1])}")
    out += ["", "## Combos", "", "J + K → Esc · A + B / S + B → previous / next tmux window",
            "", "`1×` = applies to the next key only · BT = Bluetooth device"]
    print("\n".join(out))
