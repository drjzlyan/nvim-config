# Plugins

## Phase 1

Only the plugins required for fast, comfortable editing are enabled.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `folke/lazy.nvim` | Plugin manager | No (required at startup) |
| `folke/which-key.nvim` | Discoverable keymap groups | `VeryLazy` |
| `folke/snacks.nvim` | Notifications, input, picker | No (priority 1000) |
| `stevearc/oil.nvim` | File explorer | `cmd = "Oil"` |
| `ibhagwan/fzf-lua` | Search / fuzzy picker | `VeryLazy` |
| `nvim-lualine/lualine.nvim` | Statusline | `VeryLazy` |
| `rmagatti/auto-session` | Session management | No |

## Rationale

- **No Telescope**: `fzf-lua` is used instead because it leverages the same
  `fzf`, `fd`, and `rg` binaries installed by the dotfiles repo.
- **No neo-tree / nvim-tree**: `oil.nvim` provides a buffer-like file editing
  experience with fewer concepts.
- **Minimal statusline**: `lualine` shows only the most useful information.
- **Snacks dashboard disabled**: we prefer a clean startup screen. Only
  `notifier`, `input`, and `picker` are enabled.

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
