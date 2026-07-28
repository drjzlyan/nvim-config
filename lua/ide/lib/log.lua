local M = {}

---@param level integer vim.log.levels
---@param msg string
function M.notify(level, msg)
  vim.notify(msg, level)
end

---@param msg string
function M.info(msg)
  M.notify(vim.log.levels.INFO, msg)
end

---@param msg string
function M.warn(msg)
  M.notify(vim.log.levels.WARN, msg)
end

---@param msg string
function M.error(msg)
  M.notify(vim.log.levels.ERROR, msg)
end

return M
