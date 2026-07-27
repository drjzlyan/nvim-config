# Plugins

## Phase 1

Core navigation, search, UI, and session management.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `folke/lazy.nvim` | Plugin manager | No (required at startup) |
| `folke/which-key.nvim` | Discoverable keymap groups | `VeryLazy` |
| `folke/snacks.nvim` | Notifications, input, picker | No (priority 1000) |
| `stevearc/oil.nvim` | File explorer | `cmd = "Oil"` |
| `ibhagwan/fzf-lua` | Search / fuzzy picker | `VeryLazy` |
| `nvim-lualine/lualine.nvim` | Statusline | `VeryLazy` |
| `rmagatti/auto-session` | Session management | No |

## Phase 2

Editing improvements: syntax, text objects, pairs, surround, and comments.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `nvim-treesitter/nvim-treesitter` | Syntax / indentation / incremental selection | `BufReadPost`/`BufNewFile` |
| `nvim-treesitter/nvim-treesitter-textobjects` | Function/class/block/parameter text objects | Bundled with treesitter |
| `echasnovski/mini.pairs` | Auto-close pairs | `VeryLazy` |
| `echasnovski/mini.surround` | Add/change/delete surrounding pairs | `VeryLazy` |
| `numToStr/Comment.nvim` | `gc`/`gcc` commenting | `VeryLazy` |
| `folke/todo-comments.nvim` | Highlight and search TODO/FIXME/etc. | `VeryLazy` |

## Phase 3

Language-aware editing: LSP, completion, and snippets.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `neovim/nvim-lspconfig` | LSP client configuration | Supported filetypes only |
| `saghen/blink.cmp` | Completion engine | `InsertEnter` / `CmdlineEnter` |
| `L3MON4D3/LuaSnip` | Snippet expansion engine | Bundled with completion |
| `rafamadriz/friendly-snippets` | Common snippet definitions | Bundled with completion |

## Rationale

- **No Telescope**: `fzf-lua` is used instead because it leverages the same
  `fzf`, `fd`, and `rg` binaries installed by the dotfiles repo.
- **No neo-tree / nvim-tree**: `oil.nvim` provides a buffer-like file editing
  experience with fewer concepts.
- **Minimal statusline**: `lualine` shows only the most useful information.
- **Snacks dashboard disabled**: we prefer a clean startup screen. Only
  `notifier`, `input`, and `picker` are enabled.
- **No Mason**: language servers are installed externally with Homebrew to keep
  Neovim configuration separate from toolchain management.
- **`blink.cmp`**: replaces `nvim-cmp` with a single, fast completion plugin
  that supports LSP, buffer, path, and snippet sources.

## Disabled snacks modules

- `dashboard`
- `indent`
- `scroll`
- `statuscolumn`
- `words`

These may be enabled in later phases if they solve a concrete problem.

## Disabled built-ins

The following Neovim built-in plugins are disabled in `lua/core/lazy.lua` to
reduce startup overhead:

- `gzip`
- `matchit`
- `matchparen`
- `netrwPlugin`
- `tarPlugin`
- `tohtml`
- `tutor`
- `zipPlugin`
