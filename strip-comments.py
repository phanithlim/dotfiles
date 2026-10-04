"""Remove whole-line comments from the config files in this repo.

usage: python3 strip-comments.py            (run from the repo root)
Only full-line comments go; comments after code, shebangs and text inside
Lua long strings are kept, so values like #{...} or #89b4fa are never touched.
"""
import os
import re

HASH = {".conf", ".toml", ".sh", ".py"}
HASH_FILES = {"config", "tmux-sessionizer", "tmux-colors"}
SKIP_DIRS = {".git", "docs", "assets"}


def style(path):
    name = os.path.basename(path)
    ext = os.path.splitext(name)[1]
    if ext == ".lua":
        return "lua"
    if ext == ".qml":
        return "slash"
    if ext in HASH or name in HASH_FILES:
        return "hash"
    return None


def strip_lua(lines):
    out, in_block, in_string = [], None, None
    for line in lines:
        s = line.strip()
        if in_block:
            if in_block in line:
                in_block = None
            continue
        if in_string:
            out.append(line)
            if in_string in line:
                in_string = None
            continue
        m = re.match(r"--\[(=*)\[", s)
        if m:
            close = "]" + m.group(1) + "]"
            if close not in s[m.end():]:
                in_block = close
            continue
        if s.startswith("--"):
            continue
        out.append(line)
        code = line.split("--", 1)[0]
        m = re.search(r"\[(=*)\[", code)
        if m and "]" + m.group(1) + "]" not in code[m.end():]:
            in_string = "]" + m.group(1) + "]"
    return out


def strip_prefix(lines, prefix):
    return [l for i, l in enumerate(lines)
            if not l.strip().startswith(prefix) or (i == 0 and l.startswith("#!"))]


def strip_python(lines):
    out, in_doc = [], False
    for i, line in enumerate(lines):
        s = line.strip()
        if i == 0 and line.startswith("#!"):
            out.append(line)
            continue
        if not out and not in_doc and s.startswith('"""'):
            in_doc = s.count('"""') == 1
            continue
        if in_doc:
            in_doc = '"""' not in s
            continue
        if s.startswith("#"):
            continue
        out.append(line)
    return out


def tidy(lines):
    out = []
    for line in lines:
        if not line.strip() and (not out or not out[-1].strip()):
            continue
        out.append(line)
    while out and not out[-1].strip():
        out.pop()
    return out


changed = 0
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for name in files:
        path = os.path.join(root, name)
        kind = style(path)
        if not kind or os.path.islink(path) or name == "strip-comments.py":
            continue
        text = open(path, encoding="utf-8").read()
        lines = text.split("\n")
        if kind == "lua":
            new = strip_lua(lines)
        elif kind == "slash":
            new = strip_prefix(lines, "//")
        elif path.endswith(".py"):
            new = strip_python(lines)
        else:
            new = strip_prefix(lines, "#")
        result = "\n".join(tidy(new)) + "\n"
        if result != text:
            open(path, "w", encoding="utf-8").write(result)
            changed += 1
print(f"stripped comments from {changed} files")
