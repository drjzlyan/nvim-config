# LSP

## Overview

Language support is implemented in two capability files:

- `lua/features/lsp.lua` — diagnostics, LSP keymaps, and server enablement.
- `lua/features/completion.lua` — `blink.cmp`, `blink.lib`, `LuaSnip`, and
  snippets.

Language-specific LSP wiring lives under `lua/languages/`.

This split keeps LSP and completion concerns independent.

## Neovim 0.11 APIs

The configuration uses `vim.lsp.config(name, cfg)` and `vim.lsp.enable(name)`
instead of the deprecated `lspconfig.*.setup()` framework. `nvim-lspconfig` is
still required so its server definitions are registered, but setup is handled
by Neovim's native API.

Example from `lua/features/lsp.lua`:

```lua
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable("lua_ls")
```

## Completion architecture

`saghen/blink.cmp` is the completion engine. It sources suggestions from:

1. LSP
2. Buffer
3. Path
4. Snippets

`LuaSnip` expands snippets, and `friendly-snippets` provides the snippet
definitions. Snippets are loaded lazily when a filetype with snippets is opened.

LSP completion capabilities are obtained from
`require("blink.cmp").get_lsp_capabilities()` so the LSP server setup does not
duplicate completion configuration.

## Supported language servers

Servers are installed and updated externally. Mason is not used. Selectable
language servers are installed by `scripts/install-tools.sh` based on the
user's language selection (see [`languages.md`](languages.md)).

### Always available (common/config languages)

| Server | Filetype(s) | Package |
|--------|-------------|---------|
| `lua_ls` | `lua` | `lua-language-server` |
| `jsonls` | `json` | `vscode-json-languageserver` |
| `yamlls` | `yaml` | `yaml-language-server` |
| `bashls` | `sh`, `zsh` | `bash-language-server` |
| `taplo` | `toml` | `taplo` |
| `marksman` | `markdown` | `marksman` |

Install the config-file servers:

```bash
brew install lua-language-server vscode-json-languageserver yaml-language-server bash-language-server taplo marksman
```

### Selectable (installed only when the user chooses the language)

| Server | Filetype(s) | Language | Install method |
|--------|-------------|----------|----------------|
| `basedpyright` | `python` | Python | `uv tool install` |
| `ruff` | `python` | Python | `uv tool install` |
| `jdtls` | `java` | Java | download |
| `ts_ls` | `typescript`, `javascript` | TypeScript/JS | `npm install -g` |
| `gopls` | `go` | Go | `go install` |
| `clangd` | `c`, `cpp` | C/C++ | `brew install` |
| `rust_analyzer` | `rust` | Rust | `rustup component add` |

Python and Java servers are documented in [`python.md`](python.md) and
[`java.md`](java.md). All selectable languages are documented in
[`languages.md`](languages.md).

## Diagnostics

Diagnostics are configured globally in `lua/features/lsp.lua`:

- Virtual text appears only for warnings and errors.
- Errors are underlined.
- Floating windows use rounded borders and sort by severity.
- Signs show a single letter per severity.

## LSP UI

- Hover and signature help use rounded borders via the keymap callbacks.
- Text changes are debounced by 150 ms per server.
- No automatic popups besides completion.

## Not included

- Mason
- AI coding plugins
- Generic formatting plugins (Java formatting uses `conform.nvim` with
  `google-java-format`; Python formatting uses `ruff`)
