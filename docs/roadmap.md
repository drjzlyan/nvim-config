# Roadmap

## Phase 1 — Core editing (done)

- [x] Plugin manager (`lazy.nvim`)
- [x] Discoverable keymaps (`which-key.nvim`)
- [x] Notifications / input / picker (`snacks.nvim`, dashboard disabled)
- [x] File explorer (`oil.nvim`)
- [x] Search (`fzf-lua` with `fd`/`rg`)
- [x] Statusline (`lualine.nvim`)
- [x] Sessions (`auto-session`)

Goals: startup < 100 ms, no unnecessary plugins.

## Phase 2 — Editing improvements (done)

- [x] Treesitter syntax / indentation / incremental selection
- [x] Treesitter textobjects (function, class, block, parameter)
- [x] Auto pairs (`mini.pairs`)
- [x] Surround operations (`mini.surround`)
- [x] Comments (`Comment.nvim`)
- [x] TODO/FIXME/etc. highlighting and search (`todo-comments.nvim`)

Goal: make editing excellent before adding language intelligence.

## Phase 3 — Language support (done)

- [x] LSP configuration via `nvim-lspconfig`
- [x] Completion engine (`blink.cmp`)
- [x] Snippet engine (`LuaSnip`) and snippet collection (`friendly-snippets`)
- [x] Externally managed language servers via Homebrew
- [x] Per-language modules under `lua/languages/` reserved for future use

## Phase 4 — Python development environment (done)

- [x] Python treesitter parser
- [x] `basedpyright` LSP (definition, references, rename, implementation, hover, workspace symbols, semantic tokens)
- [x] `ruff` (linting, formatting, organize imports, code actions)
- [x] Automatic virtual environment detection (`.venv`, `venv`, `uv`)
- [x] pytest commands (current file, current function, project)
- [x] Run commands (current file, current module, selected code)
- [x] Format and organize imports on save
- [x] Python keymaps and which-key group

See [`docs/python.md`](docs/python.md) for details.

## Phase 5 — Workflow integrations

- [ ] Git integration (`gitsigns.nvim` / `fugitive`)
- [ ] Debugger (`nvim-dap`)
- [ ] Formatting and linting for other languages (`conform.nvim`, `nvim-lint`)
- [ ] Additional pickers and advanced `snacks.nvim` modules as needed

## Non-goals

- Re-implementing LazyVim, NvChad, AstroNvim, or Kickstart.
- Adding plugins that overlap with existing capabilities.
- Coupling the editor to coding agents.
