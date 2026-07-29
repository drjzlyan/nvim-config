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
| `nvim-treesitter/nvim-treesitter-context` | Sticky context header (current function/class) | Bundled with treesitter |
| `echasnovski/mini.pairs` | Auto-close pairs | `VeryLazy` |
| `echasnovski/mini.surround` | Add/change/delete surrounding pairs | `VeryLazy` |
| `folke/todo-comments.nvim` | Highlight and search TODO/FIXME/etc. | `VeryLazy` |

Commenting uses Neovim 0.10's native `gc`/`gcc` operators — no plugin required.

## Phase 3

Language-aware editing: LSP, completion, diagnostics, and snippets.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `neovim/nvim-lspconfig` | LSP client configuration | Supported filetypes only |
| `saghen/blink.cmp` | Completion engine | `InsertEnter` / `CmdlineEnter` |
| `L3MON4D3/LuaSnip` | Snippet expansion engine | Bundled with completion |
| `rafamadriz/friendly-snippets` | Common snippet definitions | Bundled with completion |
| `folke/trouble.nvim` | Structured diagnostic list and LSP result viewer | `cmd` (`Trouble`, `TroubleToggle`) |
| `stevearc/conform.nvim` | Java code formatter bridge for `google-java-format` | `ft = "java"` |

## Phase 6

Git integration inside Neovim.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `lewis6991/gitsigns.nvim` | Hunk signs, blame, preview, staging, diff | Only in Git repos |
| `sindrets/diffview.nvim` | Diff current changes, branches, commits, file history | Only in Git repos |

External tools:

- `git`
- `lazygit`
- `delta` (used by `lazygit` for pager output)

## Rationale

- **No Telescope**: `fzf-lua` is used instead because it leverages the same
  `fzf`, `fd`, and `rg` binaries installed by the dotfiles repo.
- **No neo-tree / nvim-tree**: `oil.nvim` provides a buffer-like file editing
  experience with fewer concepts.
- **Minimal statusline**: `lualine` shows only the most useful information.
- **Snacks dashboard disabled**: we prefer a clean startup screen. Only
  `notifier`, `input`, `picker`, and `bigfile` are enabled.
- **No `Comment.nvim`**: Neovim 0.10+ provides native `gc`/`gcc` operators;
  no plugin is needed.
- **No Mason**: language servers are installed externally with Homebrew to keep
  Neovim configuration separate from toolchain management.
- **`blink.cmp`**: replaces `nvim-cmp` with a single, fast completion plugin
  that supports LSP, buffer, path, and snippet sources.
- **No `vim-fugitive`**: `gitsigns.nvim` handles hunk-level actions, blame, and
  diff, `diffview.nvim` handles broader diffs, and `lazygit` covers complex Git
  workflows from a floating terminal.

## Phase 7

Debugging for Python, Java, and Go.

| Plugin | Purpose | Lazy? |
|--------|---------|-------|
| `mfussenegger/nvim-dap` | Debug Adapter Protocol client | On debug command/keymap |
| `rcarriga/nvim-dap-ui` | Scopes, breakpoints, watches, call stack, REPL, console | With `nvim-dap` |
| `theHamsta/nvim-dap-virtual-text` | Inline variable values and exceptions | With `nvim-dap` |
| `nvim-neotest/nvim-nio` | Async I/O for `nvim-dap-ui` | With `nvim-dap` |
| `mfussenegger/nvim-jdtls` | jdtls DAP integration for Java | With `nvim-dap` |

External tools:

- `debugpy` (Python)
- `java-debug` + `java-test` (Java)
- `delve` (Go — `dlv` binary, installed via `go install`)

## Active snacks modules

Only the following `snacks.nvim` modules are enabled:

- `notifier` — replaces `vim.notify` with a floating notification queue
- `input` — styled `vim.ui.input` for rename and other prompts
- `picker` — picker backend used for fzf-lua fallback
- `bigfile` — automatically disables swap, undo, and syntax for files larger than 1 MB

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
