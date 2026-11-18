-- git signs and blame
-- give git popups a border and solid background
vim.api.nvim_create_autocmd("WinNew", {
  group = vim.api.nvim_create_augroup("gitsigns_popup_style", { clear = true }),
  callback = function()
    vim.schedule(function()
      -- the popup opens without focus, so check every new float, not just the current window
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.w[w].gitsigns_preview and not vim.w[w].gitsigns_styled then
          vim.w[w].gitsigns_styled = true
          vim.wo[w].winhighlight = "NormalFloat:TermPanel,FloatBorder:TermPanelDim"
        end
      end
    end)
  end,
})

-- "Dara Kim" -> "DK"
local function initials(name)
  if name == "Not Committed Yet" then
    return "new"
  end
  local letters = ""
  for word in name:gmatch("%w+") do
    letters = letters .. word:sub(1, 1)
  end
  letters = #letters > 1 and letters or name
  return letters:sub(1, 2):upper()
end

-- <leader>ghB opens the blame panel, or closes it when open
local function toggle_blame()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "gitsigns-blame" then
      return vim.api.nvim_win_close(win, true)
    end
  end
  require("gitsigns").blame()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitsigns-blame",
  callback = function(args)
    vim.keymap.set("n", "<leader>ghB", toggle_blame, { buffer = args.buf, desc = "Blame Buffer" })
  end,
})

local git_signs = {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local on_attach = opts.on_attach
    opts.on_attach = function(buf)
      if on_attach then
        on_attach(buf)
      end
      vim.keymap.set("n", "<leader>ghB", toggle_blame, { buffer = buf, desc = "Blame Buffer" })
    end
    -- blame panel like IntelliJ's annotate: "06/11/26 DK"
    opts.blame_formatter = function(_, info, fmt)
      return {
        { os.date("%m/%d/%y", info.author_time), "Comment" },
        { " " },
        { initials(info.author), fmt.hash_hl_group },
      }, false
    end
    opts.preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 1,
      col = 0,
    }
  end,
}

-- git log
-- 12-hour times in git log: "Fri 16:33" -> "Fri 4:33PM"
local function twelve_hour(item)
  if not item.date then
    return
  end
  local date = item.date:gsub("^%a%a%a (%a%a%a %d+ %d+:%d%d)$", "%1")
  item.date = date:gsub("(%d+):(%d%d)", function(h, m)
    h = tonumber(h)
    return ("%d:%s%s"):format((h + 11) % 12 + 1, m, h < 12 and "AM" or "PM")
  end)
end

local git_log = {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_log = { transform = twelve_hour },
        git_log_file = { transform = twelve_hour },
        git_log_line = { transform = twelve_hour },
      },
    },
  },
}

return {
  git_signs,
  git_log,
}
