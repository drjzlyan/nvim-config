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
│   │   ├── treesitter.lua
│   │   ├── editing.lua
│   │   ├── todo.lua
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

### Phase 1 (done)

Core editing, file navigation, search, statusline, and sessions.

Plugins:

- `lazy.nvim` — plugin manager
- `which-key.nvim` — discoverable keymaps
- `snacks.nvim` — notifications, input, picker (dashboard disabled)
- `oil.nvim` — file explorer
- `fzf-lua` — search
- `lualine.nvim` — statusline
- `auto-session` — session management

### Phase 2 (done)

Editing improvements before adding language intelligence.

Plugins:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — syntax, selection, text objects
- `mini.pairs` — auto-close pairs
- `mini.surround` — add/change/delete surrounding pairs
- `Comment.nvim` — `gc`/`gcc` commenting
- `todo-comments.nvim` — TODO/FIXME/etc. highlighting and search

### Phase 3 (done)

Language-aware editing with LSP, completion, and externally managed language
servers.

Plugins:

- `neovim/nvim-lspconfig` — LSP client configuration
- `saghen/blink.cmp` — completion engine
- `L3MON4D3/LuaSnip` — snippet engine
- `rafamadriz/friendly-snippets` — snippet collection

Configured language servers (installed via Homebrew):

- `lua_ls` — Lua
- `jsonls` — JSON
- `yamlls` — YAML
- `bashls` — Bash / Zsh
- `taplo` — TOML
- `marksman` — Markdown

### Phase 4

Git integration, debugging, formatting, and advanced pickers.

## Directory layout

| Path | Purpose |
|------|---------|
| `lua/core` | Options, keymaps, autocommands, lazy bootstrap |
| `lua/features` | One file per capability (navigation, search, treesitter, editing, todo, ui, session, which-key, lsp, completion) |
| `lua/languages` | Language-specific settings and LSP configs (future) |
| `lua/util` | Shared helper functions |
| `after` | Runtime overrides such as `ftplugin` |
| `docs` | Architecture, installation, keymaps, plugins, roadmap, treesitter, editing, lsp |

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
  - `<leader>l` — LSP
  - `<leader>d` — Debug (future)
  - `<leader>t` — Terminal (future)
- `which-key` makes every group discoverable.

## LSP architecture

LSP is split into two capability files:

- `lua/features/lsp.lua` — diagnostics, keymaps, server setup, and UI borders.
- `lua/features/completion.lua` — `blink.cmp`, `LuaSnip`, and snippets.

This separation keeps completion and LSP concerns independent.

## Completion architecture

`blink.cmp` provides completion from LSP, buffer text, paths, and snippets.
`LuaSnip` expands snippets and `friendly-snippets` supplies the snippet
definitions. Completion and LSP share capabilities via
`require("blink.cmp").get_lsp_capabilities()`.

## Supported language servers

Language servers are intentionally **not** managed by Mason. Install them with
Homebrew:

| Server | Language | Homebrew package |
|--------|----------|------------------|
| `lua_ls` | Lua | `lua-language-server` |
| `jsonls` | JSON | `vscode-json-languageserver` |
| `yamlls` | YAML | `yaml-language-server` |
| `bashls` | Bash / Zsh | `bash-language-server` |
| `taplo` | TOML | `taplo` |
| `marksman` | Markdown | `marksman` |

```bash
brew install lua-language-server vscode-json-languageserver yaml-language-server bash-language-server taplo marksman
```

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
- [`docs/treesitter.md`](docs/treesitter.md)
- [`docs/editing.md`](docs/editing.md)
- [`docs/roadmap.md`](docs/roadmap.md)
