local M = {}

---@param path string
---@return string?
function M.read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

---@param path string
---@return boolean
function M.filereadable(path)
  return vim.fn.filereadable(path) == 1
end

---@param path string
---@return boolean
function M.isdir(path)
  return vim.fn.isdir(path) == 1
end

---@param path string
---@return string
function M.basename(path)
  return vim.fn.fnamemodify(path, ":t")
end

---@param path string
---@return string
function M.dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

return M
