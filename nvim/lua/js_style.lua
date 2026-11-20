-- JS/TS/Vue: does the project format with Prettier or with ESLint (like Nuxt)?
local M = {}

local prettier_files = {
  ".prettierrc", ".prettierrc.json", ".prettierrc.yaml", ".prettierrc.yml", ".prettierrc.toml",
  ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs",
  "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs", "prettier.config.ts",
}
M.eslint_files = {
  "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", "eslint.config.ts",
  ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
}

-- true when the project has an ESLint config and no Prettier config
function M.uses_eslint(buf)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  local prettier = vim.fs.find(prettier_files, { path = dir, upward = true })[1]
  local eslint = vim.fs.find(M.eslint_files, { path = dir, upward = true })[1]
  return eslint ~= nil and prettier == nil
end

return M
