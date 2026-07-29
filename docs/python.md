# Python development environment

Phase 4 adds first-class Python support. The tools are managed externally (by
`uv`, Homebrew, or your system package manager) and wired together through
`vim.lsp.config` and `vim.lsp.enable`.

## Architecture

Python-specific configuration lives in one file:

- `lua/languages/python.lua`

Generic LSP wiring (diagnostics, hover borders, keymaps, completion
capabilities) remains in `lua/features/lsp.lua`. This keeps the core LSP
framework language-agnostic while `python.lua` owns server-specific settings,
run/test commands, and Python-only autocommands.

## External tools

These tools are assumed to be installed outside Neovim:

| Tool | Purpose | Typical install |
|------|---------|-----------------|
| `uv` | Project runner, virtual environments, package management | `brew install uv` |
| `basedpyright` / `basedpyright-langserver` | Type checking and LSP navigation | `uv tool install basedpyright` |
| `ruff` | Linting, formatting, import organization, code actions | `uv tool install ruff` |
| `pytest` | Running tests | `uv add --dev pytest` |
| `debugpy` | DAP debug adapter (Phase 7) | `uv tool install debugpy` |

Mason is not used.

## `uv` workflow

`uv` is the preferred runner. If `uv` is on `$PATH`, every run/test command uses
`uv run python ...` so the project interpreter is picked automatically. If `uv` is
not available, the configuration falls back to the detected virtual environment
interpreter or `python3`.

Create a project virtual environment:

```bash
uv venv
```

Run a script or REPL through `uv`:

```bash
uv run python my_script.py
uv run python -m pytest
```

Inside Neovim the same behavior is available through `<leader>pr`, `<leader>pt`,
etc.

## LSP servers

Python LSP servers are configured with `vim.lsp.config` and enabled with
`vim.lsp.enable` in `lua/languages/python.lua`.

### basedpyright

`basedpyright` handles:

- Go to definition / declaration
- Find references
- Rename symbol
- Go to implementation
- Hover documentation
- Workspace symbols
- Semantic tokens
- Type diagnostics

The interpreter path is detected automatically from the project root when a
Python buffer attaches. The search order is:

1. `VIRTUAL_ENV` environment variable
2. `root/.venv/bin/python` (and `Scripts/python.exe` on Windows)
3. `root/venv/bin/python` (and `Scripts/python.exe` on Windows)

This covers `venv`, `.venv`, and `uv` virtual environments, all of which default
to the `.venv` directory. The detected path is sent to `basedpyright` through a
`workspace/didChangeConfiguration` notification after the server attaches.

### Ruff

`ruff` handles:

- Linting
- Formatting
- Import organization
- Code actions (e.g., fix all)

Ruff is preferred over `basedpyright` wherever there is overlap. For example,
formatting and import organization are always delegated to Ruff.

## Keymaps

All Python keymaps are under `<leader>p` and only active in Python buffers.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pr` | n | Run current file |
| `<leader>pm` | n | Run current module |
| `<leader>ps` | v | Run selected code |
| `<leader>pt` | n | pytest current file |
| `<leader>ptf` | n | pytest current function / method |
| `<leader>ptp` | n | pytest whole project |
| `<leader>pi` | n | Organize imports |
| `<leader>pf` | n / v | Format with Ruff |
| `<leader>pv` | n | Show detected Python interpreter |

Buffer-local user commands (called by the keymaps above):

| Command | Action |
|---------|--------|
| `:PythonRunFile` | Run current file |
| `:PythonRunModule` | Run as a module (`-m`) |
| `:PythonRunSelection` | Run selected code |
| `:PythonTestFile` | pytest current file |
| `:PythonTestFunction` | pytest function under cursor |
| `:PythonTestProject` | pytest full project |
| `:PythonOrganizeImports` | Organize imports via Ruff |
| `:PythonFormat` | Format with Ruff |

## Testing

Three test commands are provided:

- `<leader>pt` — run all tests in the current file.
- `<leader>ptf` — run only the test function or class method under the cursor.
  The node ID is built from treesitter, so `file.py::ClassName::method_name` is
  constructed automatically.
- `<leader>ptp` — run the full project test suite.

No test UI plugins are used; tests run in the tmux build/test pane (or a
floating terminal outside tmux).

## Formatting and imports on save

For Python buffers only:

1. `BufWritePre` requests `source.organizeImports` from Ruff and applies it.
2. Then `vim.lsp.buf.format()` formats the buffer with Ruff.

Both steps are synchronous so the save never races with the formatter.

## Virtual environment detection

The active virtual environment is detected when a Python buffer attaches and is
passed to `basedpyright` through a `workspace/didChangeConfiguration`
notification. If no project interpreter is found, `basedpyright` falls back to
its default search behavior.

To verify which interpreter Neovim selected for the current buffer, press
`<leader>pv`.

## Performance notes

The configuration never scans entire virtual environments. Directories that are
ignored for file navigation are added to `wildignore`:

- `.venv`
- `__pycache__`
- `.pytest_cache`
- `.mypy_cache`

`basedpyright` is configured with `diagnosticMode = "openFilesOnly"` so it only
analyzes files you actually open.

## Task provider

Python is also registered as a generic task provider in `lua/languages/python.lua`.
When the current buffer is in a Python project, the `<leader>t` task keymaps
dispatch to this provider:

| Task | Command |
|------|---------|
| Build | not supported |
| Test | `uv run python -m pytest` or detected venv/python3 `pytest` |
| Run current file | `uv run python <file>` or detected interpreter |
| Run project | `uv run python -m <module>` if inside the project tree |
| Clean | remove all `__pycache__` directories under the project root |

See [`docs/tasks.md`](docs/tasks.md) for the provider API and how to add new
adapters.

## What is intentionally not included

Following the Phase 4 brief:

- Java support
- Git integration
- Debugging UI
- AI coding plugins
- Mason-managed servers
