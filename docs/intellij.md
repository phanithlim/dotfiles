# IntelliJ (IdeaVim) keybindings

Config: [`ideavim/ideavimrc`](../ideavim/ideavimrc) → `~/.ideavimrc`. Leader is `Space`.
Mode: `n` normal, `v` visual, `i` insert. **[L4 + A]** = Cornix: hold layer 4, tap A.

## General

| Keys | Mode | Action |
|---|---|---|
| `<esc>` | n | Clear search highlight |
| `<leader>ur` | n | Clear search highlight |
| `jk` | i | Exit insert mode |
| `<C-s>` | n, i | Save |
| `<A-j>` | n, v | Move line down |
| `<A-k>` | n, v | Move line up |
| `<` | v | Indent left (keep selection) |
| `>` | v | Indent right (keep selection) |
| `<leader>qq` | n | Quit IntelliJ |

## Navigation & Windows

| Keys | Mode | Action |
|---|---|---|
| `<C-h>` | n | Split left |
| `<C-j>` | n | Split below |
| `<C-k>` | n | Split above |
| `<C-l>` | n | Split right |
| `<leader>\|` | n | Split right |
| `<leader>-` | n | Split below |
| `<leader>wd` | n | Close split |
| `<leader>wm` | n | Maximize editor (hide tool windows) |

## Buffers & Tabs

| Keys | Mode | Action |
|---|---|---|
| `[b` | n | Previous tab |
| `]b` | n | Next tab |
| `<Tab>` | n | Next tab |
| `<S-Tab>` | n | Previous tab |
| `<S-l>` | n | Next tab |
| `<S-h>` | n | Previous tab |
| `<leader>bb` | n | Switch open file |
| `<leader>bd` | n | Close tab |
| `<leader>bo` | n | Close other tabs |
| `<leader>bp` | n | Pin tab |

## Files & Pickers

| Keys | Mode | Action |
|---|---|---|
| `<leader>e` | n | Project tree (focus) |
| `<leader>E` | n | Project tree (toggle) |
| `<leader>fe` | n | Project tree (focus) |
| `<leader><leader>` | n | Find file |
| `<leader>ff` | n | Find file |
| `<leader>fF` | n | Search everywhere |
| `<leader>fr` | n | Recent files |
| `<leader>fb` | n | Switch open file |
| `<leader>fn` | n | New file |
| `<leader>fp` | n | Recent projects |
| `<leader>ft` | n | Terminal |

## Search

| Keys | Mode | Action |
|---|---|---|
| `<leader>/` | n | Search in project |
| `<leader>sg` | n | Search in project |
| `<leader>sr` | n | Replace in project |
| `<leader>sw` | n, v | Search in project |
| `<leader>ss` | n | Symbols in file |
| `<leader>sS` | n | Symbols in project |
| `<leader>sc` | n | Find action |
| `<leader>sC` | n | Find action |
| `<leader>sk` | n | Find action |
| `<leader>sm` | n | Bookmarks |
| `<leader>sd` | n | Problems list |
| `<leader>st` | n | TODO list |
| `<leader>sj` | n | Recent locations (jump list) |

## Harpoon-style Files

| Keys | Mode | Action |
|---|---|---|
| `<leader>h1` | n | Mark file as 1 |
| `<leader>h2` | n | Mark file as 2 |
| `<leader>h3` | n | Mark file as 3 |
| `<leader>h4` | n | Mark file as 4 |
| `<A-1>` | n | Jump to file 1 **[L4 + A]** |
| `<A-2>` | n | Jump to file 2 **[L4 + S]** |
| `<A-3>` | n | Jump to file 3 **[L4 + D]** |
| `<A-4>` | n | Jump to file 4 **[L4 + F]** |
| `<leader>hh` | n | Bookmarks |

## Jumps

| Keys | Mode | Action |
|---|---|---|
| `<C-o>` | n | Back (also IDE jumps) |
| `<C-i>` | n | Forward (also IDE jumps) |

## Flash / Easymotion

| Keys | Mode | Action |
|---|---|---|
| `s` | n | Jump anywhere (AceJump) |

## LSP / Code

| Keys | Mode | Action |
|---|---|---|
| `gd` | n | Go to definition |
| `gD` | n | Go to type definition |
| `gr` | n | Usages (popup) |
| `gR` | n | Find usages (window) |
| `gI` | n | Go to implementation |
| `gy` | n | Go to type definition |
| `gs` | n | Go to super method |
| `K` | n | Documentation |
| `gK` | n | Parameter info |
| `<C-k>` | i | Parameter info |
| `<leader>ca` | n, v | Code action |
| `<leader>cr` | n | Rename |
| `<leader>cR` | n | Rename file |
| `<leader>cf` | n, v | Format |
| `<leader>co` | n | Organize imports |
| `<leader>cd` | n | Show error |
| `<leader>cs` | n | Structure window |
| `<leader>cg` | n | Generate code |
| `<leader>rf` | n, v | Extract method |
| `<leader>rx` | n, v | Extract variable |
| `<leader>ri` | n | Inline |
| `<leader>rs` | n | Refactor menu |

## Diagnostics

| Keys | Mode | Action |
|---|---|---|
| `]d` | n | Next error |
| `[d` | n | Previous error |
| `]e` | n | Next error |
| `[e` | n | Previous error |
| `<leader>xx` | n | Problems list |

## Git

| Keys | Mode | Action |
|---|---|---|
| `<leader>gg` | n | Commit window |
| `<leader>gs` | n | Git window |
| `<leader>gl` | n | Git log |
| `<leader>gf` | n | Git history of selection |
| `<leader>gb` | n | Git blame |
| `<leader>gB` | n | Open on GitHub |
| `]h` | n | Next change (hunk) |
| `[h` | n | Previous change (hunk) |
| `<leader>ghr` | n | Revert change (hunk) |
| `<leader>ghp` | n | Preview change (hunk) |

## Debug

| Keys | Mode | Action |
|---|---|---|
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Conditional breakpoint |
| `<leader>dc` | n | Continue |
| `<leader>dC` | n | Run to cursor |
| `<leader>di` | n | Step into |
| `<leader>dO` | n | Step over |
| `<leader>do` | n | Step out |
| `<leader>dt` | n | Stop |
| `<leader>dd` | n | Start debugging |
| `<leader>du` | n | Debug window |
| `<leader>de` | n, v | Evaluate expression |

## Test

| Keys | Mode | Action |
|---|---|---|
| `<leader>tr` | n | Run test under cursor |
| `<leader>tt` | n | Run test class |
| `<leader>tl` | n | Run last again |
| `<leader>td` | n | Debug test under cursor |
| `<leader>ts` | n | Run window |

## UI Toggles

| Keys | Mode | Action |
|---|---|---|
| `<leader>uw` | n | Toggle soft wrap |
| `<leader>ul` | n | Toggle line numbers |
| `<leader>uL` | n | Toggle relative numbers |
| `<leader>uz` | n | Distraction-free mode |
| `<leader>uZ` | n | Zen mode |
| `<leader>uf` | n | Full screen |

## Tabs

| Keys | Mode | Action |
|---|---|---|
| `<leader><tab>]` | n | Next tab |
| `<leader><tab>[` | n | Previous tab |
| `<leader><tab>d` | n | Close tab |
| `<leader><tab>o` | n | Close other tabs |

## Terminal

| Keys | Mode | Action |
|---|---|---|
| `<C-/>` | n | Terminal |
| `<C-_>` | n | Terminal |

## Tools

| Keys | Mode | Action |
|---|---|---|
| `<leader>mg` | n | Maven window |
| `<leader>mc` | n | Hide tool window |

## Built-in plugin keys

| Keys | Action |
|---|---|
| `ys{motion}{char}` / `cs{old}{new}` / `ds{char}` | Add / change / delete surrounding (surround) |
| `gc{motion}`, `gcc` | Comment (commentary) |
| `ia` / `aa` | Inside / around argument (argtextobj) |
| `ie` / `ae` | Whole file (textobj-entire) |
| `cx{motion}`, `cxx` | Exchange two pieces of text (exchange) |
| `%` | Jump between matching pairs and tags (matchit) |

## Set by hand in IntelliJ

| Settings → | Change |
|---|---|
| Plugins | Install **Which-Key** (leader popup), **IdeaVim-EasyMotion** + **AceJump** (`s`) |
| Keymap | Tool Windows → Terminal: add `Ctrl + /` (remove it from *Comment with Line Comment*) so it also closes the terminal |
| Tools → Terminal | Untick **Override IDE shortcuts** |
| Editor → General → Appearance | Smooth caret movement + smooth caret blinking |
| Editor → General → Scrolling | Smooth scrolling |
| Editor → Code Editing → Quick Documentation | Show on mouse move: off (`K` instead) |
| Editor → Vim | **Track action IDs** on, to find action names for new keys |

Close the terminal from inside it: `Alt + F12` or `Shift + Esc`.

