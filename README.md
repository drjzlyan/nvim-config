# nvim-config

A custom, capability-oriented Neovim configuration built from scratch for
speed and maintainability.

## Architecture

The configuration is organized by **capability**, not by plugin:

```
nvim-config/
├── init.lua              # Entry point
├── lazy-lock.json        # Plugin lockfile
├── lua/
│   ├── core/             # Editor fundamentals
│   │   ├── options.lua   # vim options
│   │   ├── keymaps.lua   # Non-plugin keymaps
│   │   ├── autocmds.lua  # Autocommands
│   │   └── lazy.lua      # Plugin manager bootstrap
│   ├── features/         # Capability modules
│   │   ├── navigation.lua
│   │   ├── search.lua
│   │   ├── ui.lua
│   │   ├── session.lua
│   │   └── whichkey.lua
│   ├── languages/        # Per-language configuration
│   └── util/             # Shared helpers
├── after/                # ftplugin, syntax overrides
└── docs/                 # Documentation
```

This layout makes it easy to swap plugin implementations without changing the
overall structure.

## Phases

### Phase 1 (current)

Core editing, file navigation, search, statusline, and sessions.

Plugins:

- `lazy.nvim` — plugin manager
- `which-key.nvim` — discoverable keymaps
- `snacks.nvim` — notifications, input, picker (dashboard disabled)
- `oil.nvim` — file explorer
- `fzf-lua` — search
- `lualine.nvim` — statusline
- `auto-session` — session management

### Phase 2

Treesitter, LSP, and language-specific tooling.

### Phase 3

Git integration, debugging, formatting, and advanced pickers.

## Directory layout

| Path | Purpose |
|------|---------|
| `lua/core` | Options, keymaps, autocommands, lazy bootstrap |
| `lua/features` | One file per capability (navigation, search, ui, session, which-key) |
| `lua/languages` | Language-specific settings and LSP configs (future) |
| `lua/util` | Shared helper functions |
| `after` | Runtime overrides such as `ftplugin` |
| `docs` | Architecture, keymaps, plugins, roadmap |

## Plugin philosophy

- Every plugin must solve a specific problem.
- Avoid overlapping plugins.
- Prefer built-in Neovim features when sufficient.
- Lazy-load everything possible to keep startup under 100 ms.

## Keymap philosophy

- `<Space>` is the leader key.
- Plugin features are grouped by capability:
  - `<leader>e` — Explorer
  - `<leader>f` — Files
  - `<leader>s` — Search
  - `<leader>q` — Session
  - `<leader>l` — LSP (future)
  - `<leader>d` — Debug (future)
  - `<leader>t` — Terminal (future)
- `which-key` makes every group discoverable.

## Installation

```bash
git clone https://github.com/example/nvim-config.git ~/.config/nvim
nvim
```

`lazy.nvim` bootstraps itself and installs plugins on first launch.

## Update plugins

Run `:Lazy sync` inside Neovim or:

```bash
nvim --headless +Lazy! sync +qa
```

The `lazy-lock.json` is committed for reproducibility.

## Documentation

- [`docs/architecture.md`](docs/architecture.md)
- [`docs/installation.md`](docs/installation.md)
- [`docs/plugins.md`](docs/plugins.md)
- [`docs/keymaps.md`](docs/keymaps.md)
- [`docs/roadmap.md`](docs/roadmap.md)
