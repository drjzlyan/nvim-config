local M = {}

---@param name string LSP server name
---@param opts table vim.lsp.config options
function M.setup_server(name, opts)
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end

---@param capabilities table
---@return table
function M.with_blink(capabilities)
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    return blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

return M
