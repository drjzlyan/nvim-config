local M = {}

-- Keep Python-specific configuration isolated in this file.
-- Generic LSP wiring (diagnostics, keymaps, handlers) lives in lua/features/lsp.lua.

-- ============================================================================
-- Project / virtual environment helpers
-- ============================================================================

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function project_root(bufnr)
  bufnr = bufnr or 0
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    path = vim.fn.getcwd()
  end
  return vim.fs.root(path, {
    ".git",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
  }) or vim.fs.dirname(path)
end

-- Search upward from a starting directory for a virtual environment.
-- Supports .venv, venv, and uv-managed virtual environments (which default to
-- .venv). Also respects an active VIRTUAL_ENV if one is set.
local function find_venv_python(start_path)
  local active = vim.env.VIRTUAL_ENV
  if active then
    local sep = package.config:sub(1, 1)
    local candidates = {
      active .. sep .. "bin" .. sep .. "python",
      active .. sep .. "Scripts" .. sep .. "python.exe",
    }
    for _, c in ipairs(candidates) do
      if executable(c) then
        return c
      end
    end
  end

  local dir = start_path
  local root = "/"
  while dir and dir ~= root do
    for _, venv in ipairs({ ".venv", "venv" }) do
      for _, interp in ipairs({ "bin/python", "Scripts/python.exe" }) do
        local candidate = dir .. "/" .. venv .. "/" .. interp
        if executable(candidate) then
          return candidate
        end
      end
    end
    dir = vim.fs.dirname(dir)
  end

  return nil
end

local function python_interpreter(bufnr)
  return find_venv_python(project_root(bufnr))
end

-- Build a command prefix that runs Python inside the project's environment.
-- Prefers `uv run`; falls back to the detected venv interpreter or `python3`.
local function python_cmd(bufnr)
  if executable("uv") then
    return { "uv", "run", "python" }
  end
  local interp = python_interpreter(bufnr) or "python3"
  return { interp }
end

-- ============================================================================
-- Terminal runner
-- ============================================================================

local function run_in_terminal(cmd, cwd)
  cwd = cwd or vim.fn.getcwd()
  vim.cmd("split")
  vim.fn.termopen(cmd, { cwd = cwd })
end

-- ============================================================================
-- Treesitter helpers for Python scopes
-- ============================================================================

local function current_pytest_node()
  local node = vim.treesitter.get_node()
  local parts = {}

  while node do
    local t = node:type()
    if t == "function_definition" or t == "async_function_definition" then
      for child in node:iter_children() do
        if child:type() == "identifier" then
          table.insert(parts, 1, vim.treesitter.get_node_text(child, 0))
          break
        end
      end
    elseif t == "class_definition" then
      for child in node:iter_children() do
        if child:type() == "identifier" then
          table.insert(parts, 1, vim.treesitter.get_node_text(child, 0))
          break
        end
      end
    end
    node = node:parent()
  end

  if #parts == 0 then
    return nil
  end
  return table.concat(parts, "::")
end

-- ============================================================================
-- Run commands
-- ============================================================================

local function run_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("No Python file to run", vim.log.levels.WARN)
    return
  end
  local root = project_root(bufnr)
  local cmd = python_cmd(bufnr)
  table.insert(cmd, file)
  run_in_terminal(cmd, root)
end

local function relpath(path, base)
  local prefix = base:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "\\%1") .. "[/\\]+"
  return path:gsub("^" .. prefix, "")
end

local function run_module()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    run_file()
    return
  end
  local root = project_root(bufnr)
  local rel = relpath(file, root)
  if rel == file then
    run_file()
    return
  end
  local module = rel:gsub("%.py$", ""):gsub("[/\\]", ".")
  local cmd = python_cmd(bufnr)
  table.insert(cmd, "-m")
  table.insert(cmd, module)
  run_in_terminal(cmd, root)
end

local function run_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  if start_pos[2] == 0 or end_pos[2] == 0 then
    vim.notify("No Python code selected", vim.log.levels.WARN)
    return
  end
  local vmode = vim.fn.visualmode()
  local lines = vim.fn.getregion(start_pos, end_pos, { type = vmode })
  if not lines or #lines == 0 then
    vim.notify("No Python code selected", vim.log.levels.WARN)
    return
  end
  local text = table.concat(lines, "\n") .. "\n"
  local tmp = vim.fn.tempname() .. ".py"
  local f = io.open(tmp, "w")
  if f then
    f:write(text)
    f:close()
  end
  local root = project_root(bufnr)
  local cmd = python_cmd(bufnr)
  table.insert(cmd, tmp)
  run_in_terminal(cmd, root)
end

-- ============================================================================
-- Test commands
-- ============================================================================

local function pytest_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("No Python file to test", vim.log.levels.WARN)
    return
  end
  local root = project_root(bufnr)
  local cmd = python_cmd(bufnr)
  vim.list_extend(cmd, { "-m", "pytest", file })
  run_in_terminal(cmd, root)
end

local function pytest_function()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("No Python file to test", vim.log.levels.WARN)
    return
  end
  local node = current_pytest_node()
  local target
  if node then
    target = vim.fn.fnamemodify(file, ":t") .. "::" .. node
  else
    target = vim.fn.fnamemodify(file, ":t")
  end
  local root = project_root(bufnr)
  local cmd = python_cmd(bufnr)
  vim.list_extend(cmd, { "-m", "pytest", target })
  run_in_terminal(cmd, root)
end

local function pytest_project()
  local bufnr = vim.api.nvim_get_current_buf()
  local root = project_root(bufnr)
  local cmd = python_cmd(bufnr)
  vim.list_extend(cmd, { "-m", "pytest" })
  run_in_terminal(cmd, root)
end

-- ============================================================================
-- Ruff organize imports
-- ============================================================================

local function organize_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
    },
    context = {
      diagnostics = {},
      only = { "source.organizeImports" },
    },
  }

  local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1500)
  if not results then
    return
  end

  for client_id, response in pairs(results) do
    if response.result then
      local client = vim.lsp.get_client_by_id(client_id)
      for _, action in ipairs(response.result) do
        if action.edit and client then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        elseif action.command and client then
          client:exec_cmd(action.command, { bufnr = bufnr })
        end
      end
    end
  end
end

local function format_python()
  vim.lsp.buf.format({
    bufnr = 0,
    async = false,
    filter = function(client)
      return client.name == "ruff"
    end,
  })
end

-- ============================================================================
-- Keymaps and user commands
-- ============================================================================

local function register_commands(bufnr)
  local cmds = {
    { "PythonRunFile", run_file, { desc = "Run current Python file" } },
    { "PythonRunModule", run_module, { desc = "Run current Python module" } },
    { "PythonRunSelection", run_selection, { desc = "Run selected Python code", range = true } },
    { "PythonTestFile", pytest_file, { desc = "pytest current file" } },
    { "PythonTestFunction", pytest_function, { desc = "pytest current function/class" } },
    { "PythonTestProject", pytest_project, { desc = "pytest whole project" } },
    { "PythonOrganizeImports", organize_imports, { desc = "Organize Python imports" } },
    { "PythonFormat", format_python, { desc = "Format Python with Ruff" } },
  }

  for _, c in ipairs(cmds) do
    vim.api.nvim_buf_create_user_command(bufnr, c[1], c[2], c[3])
  end
end

local function register_keymaps(bufnr)
  local map = function(keys, fn, modes, desc)
    modes = modes or "n"
    vim.keymap.set(modes, keys, fn, { buffer = bufnr, silent = true, desc = desc })
  end

  map("<leader>pr", run_file, { "n" }, "Run file")
  map("<leader>pm", run_module, { "n" }, "Run module")
  map("<leader>ps", run_selection, { "v" }, "Run selection")
  map("<leader>pt", pytest_file, { "n" }, "Test file")
  map("<leader>ptf", pytest_function, { "n" }, "Test function")
  map("<leader>ptp", pytest_project, { "n" }, "Test project")
  map("<leader>pi", organize_imports, { "n" }, "Organize imports")
  map("<leader>pf", format_python, { "n", "v" }, "Format")
  map("<leader>pv", function()
    local interp = python_interpreter(0)
    if interp then
      vim.notify("Python interpreter: " .. interp, vim.log.levels.INFO)
    else
      vim.notify("No virtual environment detected", vim.log.levels.WARN)
    end
  end, { "n" }, "Show active venv")
end

-- ============================================================================
-- LSP setup (basedpyright + Ruff)
-- ============================================================================

local function setup_lsp()
  local lspconfig = require("lspconfig")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  -- basedpyright: type checking, navigation, hover, workspace symbols, etc.
  lspconfig.basedpyright.setup({
    capabilities = capabilities,
    on_new_config = function(new_config, new_root_dir)
      local python = find_venv_python(new_root_dir)
      if python then
        new_config.settings = vim.tbl_deep_extend(
          "force",
          new_config.settings or {},
          { python = { pythonPath = python } }
        )
      end
    end,
    settings = {
      python = {
        pythonPath = python_interpreter(0),
      },
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "standard",
        },
        disableTaggedHints = true,
      },
    },
  })

  -- Ruff: linting, formatting, organize imports, code actions.
  -- Ruff is preferred over basedpyright whenever there is overlap.
  lspconfig.ruff.setup({
    capabilities = capabilities,
    init_options = {
      settings = {
        organizeImports = true,
        fixAll = true,
        lint = { enable = true },
        format = { backend = "internal" },
      },
    },
  })
end

-- ============================================================================
-- Autocommands: format and organize imports on save (Python only)
-- ============================================================================

local python_augroup = vim.api.nvim_create_augroup("PythonDev", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = python_augroup,
  pattern = "python",
  callback = function(args)
    setup_lsp()
    register_commands(args.buf)
    register_keymaps(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = python_augroup,
  pattern = "*.py",
  callback = function()
    organize_imports()
    format_python()
  end,
})

-- ============================================================================
-- Performance: keep searches and navigation out of virtual-env caches
-- ============================================================================

vim.opt.wildignore:append("*/.venv/*,*/__pycache__/*,*/.pytest_cache/*,*/.mypy_cache/*")

-- This module is loaded by lazy.nvim's `import = "languages"` mechanism.
-- It does not need to return a plugin spec, but returning an empty table keeps
-- the import convention consistent with lua/languages/init.lua.
return {}
