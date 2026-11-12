-- Let the status line show the terminal background, like the rest of the
-- editor. Lualine's auto theme paints its middle sections a solid colour, so
-- they are cleared on each theme it builds, which it does again on every
-- colorscheme change. The mode and position sections keep their colours.
return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		opts.options = opts.options or {}
		opts.options.theme = function()
			local theme = require("lualine.utils.loader").load_theme("auto")
			for _, mode in pairs(theme) do
				for _, section in ipairs({ "b", "c" }) do
					if mode[section] then
						mode[section].bg = "None"
					end
				end
			end
			return theme
		end

		-- Lualine skips floats by checking win_gettype() == "popup", but a floating preview window
		-- (oil's) reports "preview", so lualine drew a statusline in it. Never set one on a float.
		local nvim_opts = require("lualine.utils.nvim_opts")
		local set = nvim_opts.set
		nvim_opts.set = function(name, val, o)
			if o and o.window and vim.api.nvim_win_is_valid(o.window)
				and vim.api.nvim_win_get_config(o.window).relative ~= "" then
				return
			end
			return set(name, val, o)
		end

		local progress = require("config.lsp_progress")
		progress.setup()
		table.insert(opts.sections.lualine_x, 1, {
			progress.status,
			cond = progress.active,
			color = function() return { fg = Snacks.util.color("Special") } end,
		})
	end,
}
