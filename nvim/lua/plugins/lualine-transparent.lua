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

		local progress = require("config.lsp_progress")
		progress.setup()
		table.insert(opts.sections.lualine_x, 1, {
			progress.status,
			cond = progress.active,
			color = function() return { fg = Snacks.util.color("Special") } end,
		})
	end,
}
