local M = {}

---@class ide.HealthResult
---@field name string
---@field status "ok"|"missing"|"warning"|"error"
---@field version? string
---@field message? string

local function has_exec(name)
  return vim.fn.executable(name) == 1
end

local function safe_exec(cmd)
  local ok, output = pcall(vim.fn.system, cmd)
  if not ok or not output then
    return nil
  end
  local trimmed = vim.trim(output or "")
  if trimmed == "" then
    return nil
  end
  return trimmed
end

local function version_from(cmd)
  local output = safe_exec(cmd)
  if not output then
    return nil
  end
  return output:match("%d+%.?%d*%.?%d*") or output:sub(1, 60)
end

local function check_tool(name, version_cmd, install_hint)
  if not has_exec(name) then
    return { name = name, status = "missing", message = install_hint or ("Install " .. name) }
  end
  return { name = name, status = "ok", version = version_cmd and version_from(version_cmd) or nil }
end

function M.check_all()
  return {
    check_tool("rg", { "rg", "--version" }, "brew install ripgrep"),
    check_tool("fd", { "fd", "--version" }, "brew install fd"),
    check_tool("fzf", { "fzf", "--version" }, "brew install fzf"),
    check_tool("lazygit", { "lazygit", "--version" }, "brew install lazygit"),
    check_tool("jdtls", { "jdtls", "--version" }, "See scripts/install-tools.sh"),
    check_tool("basedpyright", { "basedpyright", "--version" }, "uv tool install basedpyright"),
    check_tool("ruff", { "ruff", "--version" }, "uv tool install ruff"),
    check_tool("google-java-format", { "google-java-format", "--version" }, "brew install google-java-format"),
  }
end

function M.check()
  local results = M.check_all()
  vim.health.start("ide: external tools")
  for _, item in ipairs(results) do
    if item.status == "ok" then
      local msg = item.version and (item.name .. ": " .. item.version) or (item.name .. ": installed")
      vim.health.ok(msg)
    elseif item.status == "warning" then
      vim.health.warn(item.name .. ": " .. (item.message or "warning"))
    else
      vim.health.error(item.name .. ": " .. (item.message or "missing"))
    end
  end
end

return M
