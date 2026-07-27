local M = {}

-- Registered task providers keyed by language / project type.
local providers = {}

-- Map generic task names to the terminal that should run them.
local terminal_for = {
  build = "build",
  test = "test",
  run_file = "shell",
  run_project = "shell",
  clean = "shell",
}

-- Register a task provider. A provider is a table with:
--   detect(bufnr) -> boolean
--   build(bufnr) -> cmd | nil
--   test(bufnr) -> cmd | nil
--   run_file(bufnr) -> cmd | nil
--   run_project(bufnr) -> cmd | nil
--   clean(bufnr) -> cmd | nil
-- where cmd is a string or a list of strings.
function M.register(name, provider)
  providers[name] = provider
end

function M.providers()
  return vim.tbl_keys(providers)
end

function M.detect(bufnr)
  bufnr = bufnr or 0
  for _, provider in pairs(providers) do
    if provider.detect and provider.detect(bufnr) then
      return provider
    end
  end
  return nil
end

-- Convert a command (string or list) to a single string.
local function cmd_to_string(cmd)
  if type(cmd) == "string" then
    return cmd
  end
  if type(cmd) == "table" then
    return table.concat(cmd, " ")
  end
  return tostring(cmd)
end

-- Extract command and optional cwd from a provider result.
local function normalize(result)
  if type(result) == "table" and result.cmd ~= nil then
    return result.cmd, result.cwd
  end
  return result, nil
end

-- Run a generic task for the current buffer.
function M.run(kind)
  local bufnr = vim.api.nvim_get_current_buf()
  local provider = M.detect(bufnr)

  if not provider then
    vim.notify("No task provider detected for this buffer", vim.log.levels.WARN)
    return
  end

  local fn = provider[kind]
  if not fn then
    vim.notify("Task provider does not support " .. kind, vim.log.levels.WARN)
    return
  end

  local ok, result = pcall(fn, bufnr)
  if not ok then
    vim.notify("Task provider failed: " .. tostring(result), vim.log.levels.ERROR)
    return
  end

  if not result then
    return
  end

  local cmd, cwd = normalize(result)
  local terminal = require("features.terminal")
  terminal.send(terminal_for[kind] or "shell", cmd_to_string(cmd), { dir = cwd })
end

-- Reuse the toggleterm plugin spec so this file remains a valid lazy.nvim spec
-- while exposing the task registry API. Tasks depend on the terminal layer, so
-- merging with toggleterm guarantees load order.
return {
  "akinsho/toggleterm.nvim",
  register = M.register,
  detect = M.detect,
  run = M.run,
  providers = M.providers,
}
