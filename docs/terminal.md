# Terminal workflow

Phase 8 makes the terminal the primary interface for build, test, run, and Git
operations. `akinsho/toggleterm.nvim` provides persistent, reusable terminals
that are toggled instead of recreated.

## Plugin

- `akinsho/toggleterm.nvim`

No overseer, task runners, or dispatch plugins are used. Each terminal is a
plain shell buffer.

## Dedicated terminals

Each named terminal is created once and reused for the lifetime of the Neovim
session:

| Name | Default direction | Purpose |
|------|-------------------|---------|
| `shell` | horizontal | Default interactive shell (`<leader>tt`) |
| `float` | float | Generic floating terminal (`<leader>tf`) |
| `build` | horizontal | Build commands (`<leader>tb`) |
| `test` | horizontal | Test commands (`<leader>ts`) |
| `git` | vertical | Git operations (`<leader>tg`) |
| `agent` | float | Coding agent tooling (`<leader>ta`) |

Because each terminal is stored by name, pressing a toggle key always shows the
same buffer with its history intact.

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle terminal (horizontal) |
| `<leader>tf` | Toggle floating terminal |
| `<leader>ta` | Toggle Agent terminal |
| `<leader>tg` | Toggle Git terminal |

All terminal keymaps open the terminal in insert mode.

## API

Other modules can reuse the terminal layer through `require("features.terminal")`:

```lua
local terminal = require("features.terminal")

-- Toggle a named terminal.
terminal.toggle("shell", "horizontal")

-- Send a command to a named terminal, opening it if needed.
terminal.send("build", "mvn package", { dir = "/path/to/project" })
```

## Configuration

Terminal size and floating-window options are set in `lua/features/terminal.lua`:

- Horizontal terminals default to 15 lines.
- Vertical terminals default to 40% of the screen width.
- Floating terminals default to 85% of the editor width and height.
