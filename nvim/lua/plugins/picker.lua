-- File search: file name first, Java files shown by class and package, frecency, <a-T> hides tests.
local function java_format(item, picker)
  return require("config.java_icons").format(item, picker)
end

local function hide_tests(item, ctx)
  if ctx.picker.opts.no_tests and ("/" .. item.file):find("/src/test/", 1, true) then
    return false
  end
end

local function file_source()
  return {
    format = java_format,
    transform = hide_tests,
    toggles = { no_tests = "T" },
    win = { input = { keys = { ["<a-T>"] = { "toggle_no_tests", mode = { "n", "i" } } } } },
  }
end

-- Go to Class, like IntelliJ: matches the class name only, so CDKC finds CamDigiKeyClient
local function classes()
  Snacks.picker.files(vim.tbl_extend("force", file_source(), {
    title = "Classes",
    cwd = LazyVim.root(),
    ft = "java",
    transform = function(item, ctx)
      if hide_tests(item, ctx) == false or item.file:match("%-info%.java$") then
        return false
      end
      item.text = vim.fn.fnamemodify(item.file, ":t:r")
    end,
  }))
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fj", classes, desc = "Find Java Class" },
    },
    opts = {
      picker = {
        matcher = { frecency = true },
        formatters = { file = { filename_first = true } },
        -- preview scroll on Alt+D / Alt+U, like oil and the docs popups
        win = {
          input = { keys = {
            ["<a-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<a-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          } },
          list = { keys = { ["<a-d>"] = "preview_scroll_down", ["<a-u>"] = "preview_scroll_up" } },
        },
        sources = {
          files = file_source(),
          git_files = file_source(),
          recent = { format = java_format },
          smart = { format = java_format },
          grep = { format = java_format },
        },
      },
    },
  },
}
