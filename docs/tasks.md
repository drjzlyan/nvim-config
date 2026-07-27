# Task workflow

Phase 8 adds language-agnostic task commands. Each language registers an
adapter that knows how to build, test, run, and clean projects of that type. The
generic `<leader>t` keymaps then dispatch to the adapter detected for the current
buffer.

## Generic commands

| Key | Task | Typical command |
|-----|------|-----------------|
| `<leader>tb` | Build | `mvn package`, `gradle build` |
| `<leader>tr` | Run current file | `uv run python path/to/file.py` |
| `<leader>ts` | Test | `pytest`, `mvn test`, `gradle test` |
| `<leader>tp` | Run project | `uv run python -m module` |
| `<leader>tc` | Clean | `mvn clean`, `gradle clean`, `find ... __pycache__ -exec rm -rf` |

A provider only needs to implement the commands that make sense for its
language.

## Project detection

Providers are matched by buffer. The first provider whose `detect` function
returns `true` handles the task:

- **Python** — `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile`
- **Java** — `pom.xml`, `build.gradle`, `settings.gradle`, `settings.gradle.kts`

Add more markers to the `detect` function when extending a provider.

## Provider API

A task provider is a Lua table with a `detect` function and any number of task
functions. Each task function receives the buffer number and returns either:

- `nil` — the task is not supported or cannot run in this context.
- a string or list of strings — the command to execute.
- a table `{ cmd = ..., cwd = ... }` — the command and the working directory.

```lua
local provider = {
  detect = function(bufnr)
    return vim.fn.filereadable("go.mod") == 1
  end,

  build = function(bufnr)
    return { cmd = { "go", "build", "./..." }, cwd = vim.fn.getcwd() }
  end,

  test = function(bufnr)
    return { cmd = { "go", "test", "./..." }, cwd = vim.fn.getcwd() }
  end,

  run_file = function(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == "" then
      return nil
    end
    return { cmd = { "go", "run", file }, cwd = vim.fn.getcwd() }
  end,
}
```

## Adding a new task provider

1. Create or open the language module under `lua/languages/<language>.lua`.
2. Build a provider table following the API above.
3. Register it with the task registry:

```lua
require("features.tasks").register("go", provider)
```

The generic `<leader>t` keymaps will now use the new provider for matching
buffers. No changes to `lua/features/tasks.lua` are required.

## Terminal separation

Task logic never manages terminal windows. When a task produces a command,
`lua/features/tasks.lua` forwards it to `lua/features/terminal.lua`. Each task
type is routed to a dedicated terminal:

- `build` → `build`
- `test` → `test`
- `run_file` / `run_project` / `clean` → `shell`

This keeps terminal lifecycle concerns out of language adapters.
