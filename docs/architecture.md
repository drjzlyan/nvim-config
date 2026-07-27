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
- `commands.lua` — custom commands (`:DevHealth`, `:DevInfo`, etc.).
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
| `git.lua` | Git workflow | `gitsigns.nvim`, `diffview.nvim` |
| `debugger.lua` | Debugging UI and keymaps | `nvim-dap`, `nvim-dap-ui`, `nvim-dap-virtual-text` |
| `whichkey.lua` | Discoverable keymaps | `which-key.nvim` |
| `lsp.lua` | LSP clients, diagnostics, keymaps | `nvim-lspconfig` (via `vim.lsp.config`) |
| `completion.lua` | Completion, snippets | `blink.cmp`, `blink.lib`, `LuaSnip`, `friendly-snippets` |
| `java.lua` | Java formatting | `conform.nvim` |

### `lua/languages`

Reserved for language-specific configuration and LSP servers.

| File | Language | Servers / Tools |
|------|----------|-----------------|
| `python.lua` | Python | `basedpyright`, `ruff`, `uv`, `pytest` |
| `python-debug.lua` | Python debugging | `debugpy` |
| `java.lua` | Java | `jdtls`, `google-java-format`, `maven`, `gradle` |
| `java-debug.lua` | Java debugging | `java-debug`, `java-test` |

### `lua/util`

Shared helper functions used by multiple modules.

| File | Purpose |
|------|---------|
| `helpers.lua` | Generic helpers (`has`, `dump`). |
| `project.lua` | Project root and type detection. |
| `java.lua` | JDK resolution, Lombok discovery, JDTLS command builder. |
| `health.lua` | Environment health checks used by `:DevHealth`. |

### `lua/dev`

Neovim `:checkhealth` integration.

| File | Purpose |
|------|---------|
| `health.lua` | Standard `:checkhealth dev` report. |

### `after/`

Runtime overrides such as `after/ftplugin/` and `after/plugin/`.

## Why not `plugins/oil.lua`?

Naming files after plugins makes the architecture depend on the current
technology choice. Naming files after capabilities keeps the intent stable even
if the plugin changes. For example, `navigation.lua` could switch from
`oil.nvim` to a different explorer without renaming any files.
