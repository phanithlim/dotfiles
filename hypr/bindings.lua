hl.unbind("SUPER + J")
hl.unbind("SUPER + L")
hl.unbind("SUPER + K")

hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })

o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", {
	launch = "obsidian -disable-gpu --enable-wayland-ime",
	focus = "^obsidian$",
})

o.bind("SUPER + N", "Neovide", { launch = "neovide" })
