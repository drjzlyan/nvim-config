# Terminal workflow

`akinsho/toggleterm.nvim` provides a persistent floating terminal that is toggled
instead of recreated.

## Plugin

- `akinsho/toggleterm.nvim`

No overseer, task runners, or dispatch plugins are used. The terminal is a plain
shell buffer.

## Keymap

| Key | Action |
|-----|--------|
| `<leader>t` | Toggle floating terminal |

The terminal opens in insert mode and is 85% of the editor width and height.
Toggle it again to hide it; the history is preserved.

## API

Other modules send commands through the terminal module:

```lua
local terminal = require("features.terminal")

-- Toggle the floating terminal.
terminal.toggle()

-- Send a command to the terminal, opening it if needed.
-- The first argument (name) is accepted but currently unused.
terminal.send(nil, "mvn package", { dir = "/path/to/project" })
```

## Configuration

Terminal size and floating-window options are set in `lua/features/terminal.lua`:

- Floating terminal defaults to 85% of the editor width and height.
- Border style is `curved`.
