# Task workflow

Language-agnostic task commands live under `<leader>m`. Each language module
registers a provider that knows how to build, test, run, and clean projects of
that type. The `<leader>m` keymaps dispatch to the provider detected for the
current buffer, falling back to `just` or `make` if none matches.

## Generic commands

| Key | Task | Typical command |
|-----|------|-----------------|
| `<leader>mb` | Build | `mvn package`, `cargo build`, `go build ./...`, `npm run build` |
| `<leader>ms` | Test | `pytest`, `mvn test`, `cargo test`, `go test ./...`, `npm test` |
| `<leader>mp` | Run project | `cargo run`, `go run .`, `npm start` |
| `<leader>mc` | Clean | `mvn clean`, `cargo clean`, `go clean -cache`, remove `__pycache__` |

A provider only needs to implement the commands that make sense for its language.

## Project detection

Providers are detected by buffer. The first provider whose `detect` function
returns `true` handles the task:

| Language | Marker files |
|----------|-------------|
| Python | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile` |
| Java | `pom.xml`, `build.gradle`, `settings.gradle`, `settings.gradle.kts` |
| TypeScript | `package.json` |
| Go | `go.mod` |
| C/C++ | `CMakeLists.txt`, `Makefile`, `meson.build` |
| Rust | `Cargo.toml` |

## Provider API

A task provider is a Lua table with a `detect` function and any number of task
functions. Each task function receives the buffer number and returns either:

- `nil` — the task is not supported or cannot run in this context.
- a table `{ cmd = ..., cwd = ... }` — the command and the working directory.

```lua
local provider = {
  detect = function(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(path, { "go.mod" })
    return root ~= nil
  end,

  build = function(bufnr)
    return { cmd = { "go", "build", "./..." }, cwd = vim.fn.getcwd() }
  end,

  test = function(bufnr)
    return { cmd = { "go", "test", "./..." }, cwd = vim.fn.getcwd() }
  end,

  run_file = function(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file == "" then return nil end
    return { cmd = { "go", "run", file }, cwd = vim.fs.dirname(file) }
  end,

  run_project = function()
    return { cmd = { "go", "run", "." }, cwd = vim.fn.getcwd() }
  end,

  clean = function()
    return { cmd = { "go", "clean", "-cache" }, cwd = vim.fn.getcwd() }
  end,
}
```

## Registering a new provider

1. Create or open the language module under `lua/languages/<language>.lua`.
2. Build a provider table following the API above.
3. Register it with the task system at the bottom of the file:

```lua
local ok, tasks = pcall(require, "util.tasks")
if ok and tasks.register_provider then
  tasks.register_provider("mylang", provider)
end
```

The `<leader>m` keymaps will now dispatch to the new provider for matching buffers.

## Fallback

When no provider matches the current buffer, the task system looks for a
`justfile` / `Justfile` or `Makefile` / `makefile` in the project root and runs
`just <task>` or `make <task>` respectively. If neither is found, a warning is
shown.
