# Terminal workflow

Inside tmux, shell commands are routed to the session's `build/test` pane via
the `ide-run` helper (from the dotfiles repo) instead of an in-editor
terminal. Outside tmux, `akinsho/toggleterm.nvim` provides a persistent
floating terminal as a fallback.

## Plugins

- `akinsho/toggleterm.nvim` (fallback only, when not inside tmux)

No overseer, task runners, or dispatch plugins are used.

## tmux routing

When `$TMUX` is set and `ide-run` is on `$PATH`:

- Commands are sent to the pane titled `build/test` in the current tmux
  session. The pane is reused whenever it exists and created on demand when
  it does not.
- `<leader>t` moves focus to the `build/test` pane instead of opening a
  floating terminal.

## Keymap

| Key | Action |
|-----|--------|
| `<leader>t` | Focus tmux build/test pane (toggle floating terminal outside tmux) |

## API

Other modules send commands through the terminal module:

```lua
local terminal = require("features.terminal")

-- Focus the build/test pane (tmux) or toggle the floating terminal.
terminal.toggle()

-- Send a command, opening the target if needed.
-- The first argument (name) is accepted but currently unused.
terminal.send(nil, "mvn package", { dir = "/path/to/project" })
```

## Configuration

Floating-terminal fallback options are set in `lua/features/terminal.lua`:

- Floating terminal defaults to 85% of the editor width and height.
- Border style is `curved`.
