local M = {}

local project = require("util.project")
local terminal = require("features.terminal")

local function filereadable(path)
  return vim.fn.filereadable(path) == 1
end

local function has_just(root)
  return filereadable(root .. "/justfile") or filereadable(root .. "/Justfile")
end

local function has_make(root)
  return filereadable(root .. "/Makefile") or filereadable(root .. "/makefile")
end

local function run(cmd, cwd)
  cwd = cwd or project.root()
  if type(cmd) == "table" then
    cmd = table.concat(cmd, " ")
  end
  terminal.send(nil, cmd, { dir = cwd })
end

local function task_or_notify(kind, just_cmd, make_cmd)
  local root = project.root()
  if has_just(root) then
    run(just_cmd, root)
  elseif has_make(root) then
    run(make_cmd, root)
  else
    vim.notify("No justfile or Makefile found for " .. kind, vim.log.levels.WARN)
  end
end

function M.build()
  task_or_notify("build", "just build", "make build")
end

function M.test()
  task_or_notify("test", "just test", "make test")
end

function M.clean()
  task_or_notify("clean", "just clean", "make clean")
end

function M.run_file()
  vim.notify("Run file is language-specific; use language keymaps instead", vim.log.levels.INFO)
end

function M.run_project()
  task_or_notify("run", "just run", "make run")
end

function M.setup()
  vim.api.nvim_create_user_command("TaskBuild", M.build, { desc = "Run project build task" })
  vim.api.nvim_create_user_command("TaskTest", M.test, { desc = "Run project test task" })
  vim.api.nvim_create_user_command("TaskClean", M.clean, { desc = "Run project clean task" })
  vim.api.nvim_create_user_command("TaskRun", M.run_project, { desc = "Run project run task" })
end

return M
