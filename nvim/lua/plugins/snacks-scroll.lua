return {
	"folke/snacks.nvim",
	opts = {
		scroll = {
			enabled = not vim.g.neovide,
			animate = {
				duration = { step = 10, total = 150 },
				easing = "outQuad",
			},
		},
	},
}
