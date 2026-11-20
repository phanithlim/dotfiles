-- Claude Code: <leader>i (<leader>a is Harpoon)

-- herdr: the Claude pane in this tab, or else in this workspace
local function herdr(args)
  local result = vim.system(vim.list_extend({ "herdr" }, args), { text = true }):wait(2000)
  local ok, data = pcall(vim.json.decode, result.stdout or "")
  return ok and data.result or nil
end

local function claude_pane()
  local current = herdr({ "pane", "current" })
  local list = herdr({ "pane", "list" })
  if not (current and list) then
    return nil
  end
  local here, found = current.pane, nil
  for _, pane in ipairs(list.panes) do
    if pane.agent == "claude" and pane.workspace_id == here.workspace_id then
      if pane.tab_id == here.tab_id then
        return pane
      end
      found = found or pane
    end
  end
  return found
end

-- type "@path#L10-20 " into Claude's prompt: the file, or the selected lines
local function send_to_claude_pane()
  local pane = claude_pane()
  if not pane then
    return Snacks.notify.warn("No Claude pane in this herdr workspace")
  end
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = pane.foreground_cwd or pane.cwd
  local path = file:find(cwd .. "/", 1, true) == 1 and file:sub(#cwd + 2) or file
  local ref = "@" .. path
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local from, to = vim.fn.line("v"), vim.fn.line(".")
    from, to = math.min(from, to), math.max(from, to)
    ref = ref .. "#L" .. from .. (to > from and ("-" .. to) or "")
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  end
  vim.system({ "herdr", "pane", "send-text", pane.pane_id, ref .. " " })
  Snacks.notify.info("Sent " .. ref .. " to Claude")
end

return {
  {
    -- connects to Claude Code (/ide in Claude): it sees your selection, its edits open as diffs here
    "coder/claudecode.nvim",
    opts = {},
    keys = {
      { "<leader>i", "", desc = "+claude", mode = { "n", "v" } },
      { "<leader>ic", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>if", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ir", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>iC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>ib", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>is", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
      { "<leader>ia", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>id", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      { "<leader>ih", send_to_claude_pane, mode = { "n", "v" }, desc = "Send to Claude pane (herdr)" },
    },
  },
}
