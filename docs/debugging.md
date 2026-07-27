# Debugging

Phase 7 adds a production-quality debugging experience for Python and Java.

## Plugins

- `mfussenegger/nvim-dap` — Debug Adapter Protocol client
- `rcarriga/nvim-dap-ui` — debugging UI
- `theHamsta/nvim-dap-virtual-text` — inline values and exceptions
- `nvim-neotest/nvim-nio` — async I/O used by the UI
- `mfussenegger/nvim-jdtls` — jdtls DAP integration helper

## External tools

Install these outside Neovim:

```bash
# Python
pip install debugpy

# Java
# Install java-debug and java-test via your preferred method (e.g. Homebrew or
# by downloading the VS Code Java extension JARs).
```

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue / start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>du` | Toggle DAP UI |
| `<leader>dt` | Terminate session |
| `<leader>dx` | Clear all breakpoints |

The debugger and all related plugins load only when one of these keymaps or
DAP commands is used.

## DAP UI

`nvim-dap-ui` shows:

- Scopes
- Breakpoints
- Watches
- Call Stack
- REPL
- Console

It opens automatically when a debug session starts and closes when the session
ends. Use `<leader>du` to toggle it manually.

## Breakpoints

- **Toggle breakpoint**: `<leader>db` on the current line.
- **Conditional breakpoint**: `<leader>dB` and enter a condition.
- **Logpoint**: call `require("dap").set_breakpoint(nil, nil, "message")` or use
  the REPL.
- **Clear all breakpoints**: `<leader>dx`.

## Python debugging

`debugpy` is configured in `lua/languages/python-debug.lua`.

Available configurations when you press `<leader>dc` in a Python buffer:

- **Launch current file** — runs the file in the active buffer.
- **Launch module** — prompts for a module name.
- **Attach to process** — pick a running process.
- **Attach to running debugpy** — attach to `127.0.0.1:5678`.

Virtual environment detection order:

1. `VIRTUAL_ENV` environment variable.
2. `.venv/bin/python` or `venv/bin/python` in the project root.
3. System `python3` / `python`.

## Java debugging

Java debugging reuses the existing `jdtls` workspace from Phase 5.
`java-debug` and `java-test` bundles are discovered from common Homebrew
installation paths and loaded into `jdtls` on attach.

When you start debugging in a Java buffer, `nvim-jdtls` discovers the main
classes in the project and presents them as launch configurations. Pick one
and the session starts.

For **attach mode**, a static configuration is provided to connect to a JVM
listening on `127.0.0.1:5005`.

## REPL

Open the DAP REPL with `<leader>dr`. It supports evaluating expressions and
uses the active debug session for completion.
