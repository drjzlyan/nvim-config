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

## Phase 2 — Language support

- [ ] Treesitter for syntax highlighting and incremental selection
- [ ] LSP configuration via `nvim-lspconfig`
- [ ] Completion engine (`nvim-cmp` or built-in `snacks` completion if available)
- [ ] Per-language modules under `lua/languages/`

Initial languages: Lua, Python, Java, TypeScript/JavaScript.

## Phase 3 — Workflow integrations

- [ ] Git integration (`gitsigns.nvim` / `fugitive`)
- [ ] Debugger (`nvim-dap`)
- [ ] Formatting and linting (`conform.nvim`, `nvim-lint`)
- [ ] Additional pickers and advanced `snacks.nvim` modules as needed

## Non-goals

- Re-implementing LazyVim, NvChad, AstroNvim, or Kickstart.
- Adding plugins that overlap with existing capabilities.
- Coupling the editor to coding agents.
