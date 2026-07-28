-- Language dispatcher: reads the user's language selection and conditionally
-- loads the corresponding language modules.  Common languages (JSON, YAML,
-- Bash, Lua, TOML, Markdown) are always available via lua/features/lsp.lua.
--
-- The selection file lives in Neovim's data directory so it is machine-local
-- and never committed to the repository:
--   ~/.local/share/nvim/languages.local
--
-- Format: one language per line, comments start with #.  Example:
--   python
--   java
--   typescript
--   go

local M = {}

--- Path to the language selection file.
M.config_path = vim.fn.stdpath("data") .. "/languages.local"

--- All languages this configuration knows how to set up.
--- Common languages (json, yaml, bash, lua, toml, markdown) are always on
--- and are NOT listed here because they are handled by features/lsp.lua.
M.available = {
  "python",
  "java",
  "typescript",
  "go",
  "cpp",
  "rust",
}

--- Read the language selection file and return the list of selected languages.
--- If the file does not exist, returns an empty table (all modules stay
--- inactive until the user runs the selector).
---@return string[]
function M.selected()
  local langs = {}
  local f = io.open(M.config_path, "r")
  if not f then
    return langs
  end
  for line in f:lines() do
    line = line:gsub("#.*", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if line ~= "" then
      table.insert(langs, line)
    end
  end
  f:close()
  return langs
end

--- Check whether a language is selected.
---@param lang string
---@return boolean
function M.is_enabled(lang)
  for _, l in ipairs(M.selected()) do
    if l == lang then
      return true
    end
  end
  return false
end

-- Conditionally require each selected language module.
-- Each module returns a table of lazy.nvim specs (possibly empty) and has
-- side effects (autocmds, LSP setup, keymaps) that run on require.
local specs = {}

for _, lang in ipairs(M.selected()) do
  local ok, mod = pcall(require, "languages." .. lang)
  if ok and type(mod) == "table" then
    vim.list_extend(specs, mod)
  end
end

return specs
