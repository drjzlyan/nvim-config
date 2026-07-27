local M = {}

-- Persistent terminal objects keyed by name.
local terminals = {}

-- Default layout for each named terminal. Keeping a single object per name
-- guarantees reuse: the same terminal is toggled, never duplicated.
local defaults = {
  shell = { direction = "horizontal" },
  build = { direction = "horizontal" },
  test = { direction = "horizontal" },
  git = { direction = "vertical" },
  agent = { direction = "float" },
  float = { direction = "float" },
}

function M.setup()
  require("toggleterm").setup({
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    open_mapping = nil,
    hide_numbers = true,
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      winblend = 0,
      width = function()
        return math.floor(vim.o.columns * 0.85)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.85)
      end,
    },
  })
end

-- Create or reuse a named terminal.
function M.get(name, opts)
  opts = opts or {}
  local base = defaults[name] or { direction = "horizontal" }

  if not terminals[name] then
    local Terminal = require("toggleterm.terminal").Terminal
    terminals[name] = Terminal:new(vim.tbl_deep_extend("force", {
      cmd = opts.cmd,
      dir = opts.dir,
      direction = opts.direction or base.direction,
      display_name = name,
      close_on_exit = false,
      hidden = false,
      on_open = function()
        vim.cmd("startinsert!")
      end,
    }, opts))
  end

  return terminals[name]
end

-- Toggle a named terminal. Direction is only honoured the first time the
-- terminal is created; afterwards the existing object is reused.
function M.toggle(name, direction)
  M.get(name, { direction = direction }):toggle()
end

-- Send a command to a named terminal, opening it first if necessary so the
-- command is not lost on a closed terminal job.
function M.send(name, cmd, opts)
  local term = M.get(name, opts or {})
  if not term:is_open() then
    term:open()
  end
  term:send(cmd)
end

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    M.setup()
  end,
  keys = {
    { "<leader>tt", function() M.toggle("shell", "horizontal") end, desc = "Toggle terminal" },
    { "<leader>tf", function() M.toggle("float", "float") end, desc = "Floating terminal" },
    { "<leader>ta", function() M.toggle("agent", "float") end, desc = "Agent terminal" },
    { "<leader>tg", function() M.toggle("git", "vertical") end, desc = "Git terminal" },
    { "<leader>tb", function() require("features.tasks").run("build") end, desc = "Run build" },
    { "<leader>tr", function() require("features.tasks").run("run_file") end, desc = "Run current file" },
    { "<leader>ts", function() require("features.tasks").run("test") end, desc = "Run tests" },
    { "<leader>tp", function() require("features.tasks").run("run_project") end, desc = "Run project" },
    { "<leader>tc", function() require("features.tasks").run("clean") end, desc = "Clean" },
  },
  -- Expose the terminal API to other modules.
  get = M.get,
  toggle = M.toggle,
  send = M.send,
}
