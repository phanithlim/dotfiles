import re
import sys

NAMES = {
    "AceAction": "Jump anywhere (AceJump)",
    "ActivateCommitToolWindow": "Commit window",
    "ActivateDebugToolWindow": "Debug window",
    "ActivateMavenToolWindow": "Maven window",
    "ActivateProblemsViewToolWindow": "Problems list",
    "ActivateRunToolWindow": "Run window",
    "ActivateStructureToolWindow": "Structure window",
    "ActivateTerminalToolWindow": "Terminal",
    "ActivateTODOToolWindow": "TODO list",
    "ActivateVersionControlToolWindow": "Git window",
    "AddConditionalBreakpoint": "Conditional breakpoint",
    "Annotate": "Git blame",
    "Back": "Back (also IDE jumps)",
    "CloseAllEditorsButActive": "Close other tabs",
    "CloseContent": "Close tab",
    "ContextDebug": "Debug test under cursor",
    "ContextRun": "Run test under cursor",
    "Debug": "Start debugging",
    "EditorToggleShowLineNumbers": "Toggle line numbers",
    "EditorToggleUseSoftWraps": "Toggle soft wrap",
    "EvaluateExpression": "Evaluate expression",
    "Exit": "Quit IntelliJ",
    "ExtractMethod": "Extract method",
    "FileStructurePopup": "Symbols in file",
    "FindInPath": "Search in project",
    "FindUsages": "Find usages (window)",
    "Forward": "Forward (also IDE jumps)",
    "Generate": "Generate code",
    "Github.Open.In.Browser": "Open on GitHub",
    "GotoAction": "Find action",
    "GotoDeclaration": "Go to definition",
    "GotoFile": "Find file",
    "GotoImplementation": "Go to implementation",
    "GotoNextError": "Next error",
    "GotoPreviousError": "Previous error",
    "GotoSuperMethod": "Go to super method",
    "GotoSymbol": "Symbols in project",
    "GotoTypeDeclaration": "Go to type definition",
    "HideActiveWindow": "Hide tool window",
    "HideAllWindows": "Maximize editor (hide tool windows)",
    "Inline": "Inline",
    "IntroduceVariable": "Extract variable",
    "ManageRecentProjects": "Recent projects",
    "MoveLineDown": "Move line down",
    "MoveLineUp": "Move line up",
    "NewFile": "New file",
    "NextTab": "Next tab",
    "OptimizeImports": "Organize imports",
    "ParameterInfo": "Parameter info",
    "PinActiveEditorTab": "Pin tab",
    "PreviousTab": "Previous tab",
    "QuickJavaDoc": "Documentation",
    "RecentFiles": "Recent files",
    "RecentLocations": "Recent locations (jump list)",
    "Refactorings.QuickListPopupAction": "Refactor menu",
    "ReformatCode": "Format",
    "RenameElement": "Rename",
    "RenameFile": "Rename file",
    "ReplaceInPath": "Replace in project",
    "Rerun": "Run last again",
    "Resume": "Continue",
    "RunClass": "Run test class",
    "RunToCursor": "Run to cursor",
    "SaveAll": "Save",
    "SearchEverywhere": "Search everywhere",
    "ShowBookmarks": "Bookmarks",
    "ShowErrorDescription": "Show error",
    "ShowIntentionActions": "Code action",
    "ShowUsages": "Usages (popup)",
    "SplitHorizontally": "Split below",
    "SplitVertically": "Split right",
    "StepInto": "Step into",
    "StepOut": "Step out",
    "StepOver": "Step over",
    "Stop": "Stop",
    "Switcher": "Switch open file",
    "ToggleDistractionFreeMode": "Distraction-free mode",
    "ToggleFullScreen": "Full screen",
    "ToggleLineBreakpoint": "Toggle breakpoint",
    "ToggleZenMode": "Zen mode",
    "Unsplit": "Close split",
    "Vcs.RollbackChangedLines": "Revert change (hunk)",
    "VcsShowCurrentChangeMarker": "Preview change (hunk)",
    "Vcs.ShowHistoryForBlock": "Git history of selection",
    "Vcs.Show.Log": "Git log",
    "VcsShowNextChangeMarker": "Next change (hunk)",
    "VcsShowPrevChangeMarker": "Previous change (hunk)",
}
for i in range(1, 10):
    NAMES[f"GotoBookmark{i}"] = f"Jump to file {i}"
    NAMES[f"ToggleBookmark{i}"] = f"Mark file as {i}"

VIM = {
    ":nohlsearch<CR>": "Clear search highlight",
    "<Esc>": "Exit insert mode",
    "<gv": "Indent left (keep selection)",
    ">gv": "Indent right (keep selection)",
    "<C-w>h": "Split left",
    "<C-w>j": "Split below",
    "<C-w>k": "Split above",
    "<C-w>l": "Split right",
    ":NERDTreeFocus<CR>": "Project tree (focus)",
    ":NERDTreeToggle<CR>": "Project tree (toggle)",
    ":set relativenumber!<CR>": "Toggle relative numbers",
}

PLUGINS = [
    ("`ys{motion}{char}` / `cs{old}{new}` / `ds{char}`", "Add / change / delete surrounding (surround)"),
    ("`gc{motion}`, `gcc`", "Comment (commentary)"),
    ("`ia` / `aa`", "Inside / around argument (argtextobj)"),
    ("`ie` / `ae`", "Whole file (textobj-entire)"),
    ("`cx{motion}`, `cxx`", "Exchange two pieces of text (exchange)"),
    ("`%`", "Jump between matching pairs and tags (matchit)"),
]

def describe(rhs):
    m = re.search(r"(?::action |<Action>\()([A-Za-z0-9._]+)", rhs)
    if m:
        return NAMES.get(m.group(1), re.sub(r"(?<=[a-z])(?=[A-Z])", " ", m.group(1)))
    return VIM.get(rhs.strip(), f"`{rhs.strip()}`")

def key(lhs):
    return "`" + lhs.replace("\\|", "|").replace("|", "\\|") + "`"

sections, current, seen = [], None, {}
lines = open(sys.argv[1]).read().split("\n")
for i, line in enumerate(lines):
    s = line.strip()
    is_header = (
        s.startswith('" ---') and i + 2 < len(lines)
        and not lines[i + 1].strip().startswith('" ---') and lines[i + 2].strip().startswith('" ---')
    )
    if is_header:
        title = re.sub(r"\s*\(.*\)$", "", lines[i + 1].strip().lstrip('"').strip())
        title = title.split(":")[0]
        title = " ".join(w if w in ("LSP", "UI", "&", "/") else w.capitalize() for w in title.split())
        current = {"title": title, "rows": []}
        sections.append(current)
        continue
    m = re.match(r"^\s*([nvix]?)(?:nore)?map\s+(\S+)\s+(.+?)\s*$", line)
    if not m or current is None:
        continue
    mode, lhs, rhs = m.groups()
    mode = {"": "n, v", "n": "n", "v": "v", "x": "v", "i": "i"}[mode]
    desc = describe(rhs)
    ident = (lhs, desc)
    if ident in seen:
        row = seen[ident]
        if mode not in row[1]:
            row[1] = row[1] + ", " + mode
        continue
    row = [lhs, mode, desc]
    seen[ident] = row
    current["rows"].append(row)

out = ["# IdeaVim (IntelliJ) keybindings", "",
       "Config: [`ideavim/ideavimrc`](../ideavim/ideavimrc) → `~/.ideavimrc`. Leader is `Space`.",
       "Mode: `n` normal, `v` visual, `i` insert. **[L4 + A]** = Cornix: hold layer 4, tap A.", ""]
for sec in sections:
    if not sec["rows"]:
        continue
    out += [f"## {sec['title']}", "", "| Keys | Mode | Action |", "|---|---|---|"]
    for lhs, mode, desc in sec["rows"]:
        if lhs.startswith("<A-") and lhs[3:4].isdigit():
            desc += f" **[L4 + {'ASDF'[int(lhs[3]) - 1]}]**"
        out.append(f"| {key(lhs)} | {mode} | {desc} |")
    out.append("")
out += ["## Built-in plugin keys", "", "| Keys | Action |", "|---|---|"]
out += [f"| {k} | {d} |" for k, d in PLUGINS]
out += ["", "## Set by hand in IntelliJ", "",
        "| Settings → | Change |", "|---|---|",
        "| Plugins | Install **Which-Key** (leader popup), **IdeaVim-EasyMotion** + **AceJump** (`s`) |",
        "| Keymap | Tool Windows → Terminal: add `Ctrl + /` (remove it from *Comment with Line Comment*) so it also closes the terminal |",
        "| Tools → Terminal | Untick **Override IDE shortcuts** |",
        "| Editor → General → Appearance | Smooth caret movement + smooth caret blinking |",
        "| Editor → General → Scrolling | Smooth scrolling |",
        "| Editor → Code Editing → Quick Documentation | Show on mouse move: off (`K` instead) |",
        "| Editor → Vim | **Track action IDs** on, to find action names for new keys |",
        "", "Close the terminal from inside it: `Alt + F12` or `Shift + Esc`.", ""]
print("\n".join(out))
