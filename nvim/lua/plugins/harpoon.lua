local function list()
  return require("harpoon"):list()
end

local function pick()
  local items = {}
  for i = 1, list():length() do
    local item = list():get(i)
    if item and item.value ~= "" then
      table.insert(items, { idx = i, text = item.value, file = vim.fn.fnamemodify(item.value, ":p") })
    end
  end
  Snacks.picker({ title = "Harpoon", items = items, format = "file", preview = "file" })
end

local keys = {
  { "<leader>h", "", desc = "+harpoon" },
  { "<leader>a", function() list():add() end, desc = "Harpoon Add" },
  { "<leader>hc", function() list():clear() require("config.harpoon_bar").update() end, desc = "Harpoon Clear All" },
  { "<leader>hh", pick, desc = "Harpoon Picker" },
  { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(list()) end, desc = "Harpoon Menu" },
  { "<C-p>", function() list():prev() end, desc = "Harpoon Prev" },
  { "<C-n>", function() list():next() end, desc = "Harpoon Next" },
}
for i = 1, 4 do
  table.insert(keys, { "<leader>" .. i, function() list():select(i) end, desc = "Harpoon " .. i })
  table.insert(keys, { "<M-" .. i .. ">", function() list():select(i) end, desc = "Harpoon " .. i })
  table.insert(keys, { "<leader>h" .. i, function() list():replace_at(i) end, desc = "Harpoon Set Slot " .. i })
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 4,
        },
        settings = {
          save_on_toggle = true,
          key = function()
            local root = vim.fs.root(0, ".git")
            return root or vim.loop.cwd()
          end,
        },
      })

      local bar = require("config.harpoon_bar")
      local function refresh()
        vim.schedule(bar.update)
      end
      harpoon:extend({ ADD = refresh, REMOVE = refresh, REPLACE = refresh, REORDER = refresh, LIST_CHANGE = refresh })
      bar.setup()
    end,
    keys = keys,
  },
}
