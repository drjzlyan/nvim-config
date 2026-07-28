local M = {}

local terminal = nil

local function get_terminal()
  if terminal == nil then
    local Terminal = require("toggleterm.terminal").Terminal
    terminal = Terminal:new({
      direction = "float",
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.85)
        end,
      },
      on_open = function()
        vim.cmd("startinsert!")
      end,
    })
  end
  return terminal
end

function M.toggle()
  get_terminal():toggle()
end

function M.send(_, cmd, opts)
  opts = opts or {}
  local term = get_terminal()
  if not term:is_open() then
    term:open()
  end
  if opts.dir then
    term:change_dir(opts.dir)
  end
  term:send(cmd)
end

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>t", function() M.toggle() end, desc = "Toggle floating terminal" },
  },
  config = function()
    require("toggleterm").setup({
      open_mapping = nil,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.85)
        end,
      },
    })
  end,
  toggle = M.toggle,
  send = M.send,
}
