# Architecture

## Design goals

1. **Capability-oriented**: organize by what the editor does, not by plugin name.
2. **Minimal startup time**: lazy-load every plugin that does not need to be
   present immediately.
3. **Easy to extend**: new capabilities get a new file under `lua/features/`.
4. **No editor/LSP coupling to agents**: coding agents run in the terminal and
   do not depend on Neovim plugins.

## Module responsibilities

### `lua/core`

Configures Neovim itself:

- `options.lua` — `vim.opt` and `vim.g` settings.
- `keymaps.lua` — non-plugin keymaps.
- `autocmds.lua` — autocommands.
- `lazy.lua` — bootstraps `lazy.nvim` and loads specs from `features` and
  `languages`.

### `lua/features`

Each file returns a list of lazy.nvim specs that implement one capability:

| File | Capability | Plugins |
|------|------------|---------|
| `navigation.lua` | File tree | `oil.nvim` |
| `search.lua` | Search / pickers | `fzf-lua` |
| `ui.lua` | Statusline / notifications | `lualine.nvim`, `snacks.nvim` |
| `session.lua` | Session management | `auto-session` |
| `whichkey.lua` | Discoverable keymaps | `which-key.nvim` |
| `lsp.lua` | LSP clients, diagnostics, keymaps | `nvim-lspconfig` |
| `completion.lua` | Completion, snippets | `blink.cmp`, `LuaSnip`, `friendly-snippets` |

### `lua/languages`

Reserved for language-specific configuration and LSP servers.

| File | Language | Servers / Tools |
|------|----------|-----------------|
| `python.lua` | Python | `basedpyright`, `ruff`, `uv`, `pytest` |

### `lua/util`

Shared helper functions used by multiple modules.

### `after/`

Runtime overrides such as `after/ftplugin/` and `after/plugin/`.

## Why not `plugins/oil.lua`?

Naming files after plugins makes the architecture depend on the current
technology choice. Naming files after capabilities keeps the intent stable even
if the plugin changes. For example, `navigation.lua` could switch from
`oil.nvim` to a different explorer without renaming any files.
