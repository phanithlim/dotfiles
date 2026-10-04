import json, re, sys
N = {"ESCAPE":"Esc","LCTRL":"Ctrl","LSHIFT":"Shift","CAPSLOCK":"Caps","LGUI":"Super","LALT":"Alt","BSPACE":"Bksp",
     "ENTER":"Enter","BSLASH":"\\","SLASH":"/","DOT":".","COMMA":",","SCOLON":";","QUOTE":"'","GRAVE":"`","MINUS":"-",
     "EQUAL":"=","LBRACKET":"[","RBRACKET":"]","TAB":"Tab","SPACE":"Space","DELETE":"Del","PSCREEN":"Print","MUTE":"Mute",
     "BTN3":"Mid-click","UP":"↑","DOWN":"↓","LEFT":"←","RIGHT":"→","VOLD":"Vol-","VOLU":"Vol+","WH_U":"Wheel↑","WH_D":"Wheel↓","TRNS":"▽"}
MOD = {"LGUI":"Super+","LCTL":"Ctrl+","LALT":"Alt+","LSFT":"Shift+","SGUI":"Super+Shift+","LCG":"Ctrl+Super+","LAG":"Super+Alt+"}
TAPHOLD = {"LGUI_T":"Super","LCTL_T":"Ctrl"}
def name(k):
    if k in ("KC_NO", -1, None): return ""
    if not isinstance(k, str): return str(k)
    m = re.fullmatch(r"(\w+)\((.+)\)", k)
    if m:
        f, a = m.groups()
        if f == "MO": return f"**L{a}**"
        if f in TAPHOLD: return f"{name(a)}/{TAPHOLD[f]}"
        if f == "OSM": return "1×" + {"MOD_LGUI":"Super","MOD_LALT":"Alt","MOD_LCTL":"Ctrl","MOD_LSFT":"Shift"}.get(a, a)
        if f in MOD: return MOD[f] + name(a)
        return k
    if re.fullmatch(r"M\d+", k): return f"Macro {k[1:]}"
    if k.startswith("USER"): return f"User {k[4:]}"
    if k.startswith("0x"):
        v = int(k, 16)
        mods = "".join(n for bit, n in ((8, "Super+"), (1, "Ctrl+"), (4, "Alt+"), (2, "Shift+")) if (v >> 8) & bit)
        basic = {0x0F: "L", 0x28: "Enter", 0x2C: "Space"}.get(v & 0xFF)
        return mods + basic if mods and basic else f"`{k}`"
    k = k.replace("KC_", "")
    return N.get(k, k)
def cell(s): return s.replace("|", "\\|") or "·"
def side(layer, rows, reverse):
    out = []
    for r in rows:
        keys = [x for x in layer[r][:6]]
        if reverse: keys = keys[::-1]
        out.append([cell(name(x)) for x in keys])
    return out
if __name__ == "__main__":
    d = json.load(open(sys.argv[1]))
    knobs = []
    for i, layer in enumerate(d["layout"]):
        if all(x in ("KC_NO", -1, "KC_MUTE", "KC_BTN3", "KC_TRNS") for row in layer for x in row): continue
        print(f"\n### Layer {i}\n")
        L = side(layer, [0, 1, 2, 3], False)
        R = side(layer, [4, 5, 6, 7], True)
        print("| L1 | L2 | L3 | L4 | L5 | L6 | | R1 | R2 | R3 | R4 | R5 | R6 |")
        print("|" + "---|" * 13)
        for l, r in zip(L, R):
            print("| " + " | ".join(l) + " | | " + " | ".join(r) + " |")
        enc = d["encoder_layout"][i]
        knobs.append(f"| {i} | {name(enc[0][0])} / {name(enc[0][1])} | {name(enc[1][0])} / {name(enc[1][1])} |")
    print("\n### Knobs (turn left / right)\n")
    print("| Layer | Left knob | Right knob |\n|---|---|---|")
    print("\n".join(knobs))
    print("\n### Combos\n")
    print("| Press together | Sends |\n|---|---|")
    for c in d["combo"]:
        if c[-1] != "KC_NO":
            idx = int(c[-1][1:])
            m = d["macro"][idx]
            taps = [ "+".join(name(x) for x in a[1:]) for a in m if a[0] == "tap" ]
            downs = [ "+".join(name(x) for x in a[1:]) for a in m if a[0] == "down" ]
            sends = " ".join(f"{dn}+{t}" for dn, t in zip(downs, taps)) if taps else name(c[-1])
            print(f"| {' + '.join(name(x) for x in c[:4] if x != 'KC_NO')} | {sends} |")
