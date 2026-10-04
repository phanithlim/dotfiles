-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Caelestia launcher.
-- o.bind("SUPER + A", "App launcher", "caelestia shell drawers toggle launcher")

-- Use Zen instead of the Omarchy browser.
-- hl.unbind("SUPER + SHIFT + B")
-- o.bind("SUPER + SHIFT + B", "Browser", { launch = "zen-browser" })

-- Free up Super+J and Super+K, which are used for stacking by default
hl.unbind("SUPER + J")
hl.unbind("SUPER + L")
hl.unbind("SUPER + K")

-- Vim-style focus movement
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
o.bind("SUPER + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
-- Obsidian needs software rendering and Wayland IME.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", {
	launch = "obsidian -disable-gpu --enable-wayland-ime",
	focus = "^obsidian$",
})

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Neovide
o.bind("SUPER + N", "Neovide", { launch = "neovide" })
