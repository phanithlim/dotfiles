hl.config({
	input = {
		kb_layout = "us,kh",
		kb_options = "grp:alt_shift_toggle",

		repeat_rate = 40,
		repeat_delay = 600,
		follow_mouse = 1,
		numlock_by_default = true,

		touchpad = {
			scroll_factor = 0.4,
		},
	},
})
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
