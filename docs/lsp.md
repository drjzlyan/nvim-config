# LSP

## Overview

Language support is implemented in two capability files:

- `lua/features/lsp.lua` — diagnostics, LSP keymaps, handlers, and server setup
- `lua/features/completion.lua` — `blink.cmp`, `LuaSnip`, and snippets

This split keeps LSP and completion concerns independent.

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

Servers are installed and updated externally with Homebrew. Mason is not used.

| Server | Filetype(s) | Homebrew package |
|--------|-------------|------------------|
| `lua_ls` | `lua` | `lua-language-server` |
| `jsonls` | `json` | `vscode-json-languageserver` |
| `yamlls` | `yaml` | `yaml-language-server` |
| `bashls` | `sh`, `zsh` | `bash-language-server` |
| `taplo` | `toml` | `taplo` |
| `marksman` | `markdown` | `marksman` |

Install all supported servers:

```bash
brew install lua-language-server vscode-json-languageserver yaml-language-server bash-language-server taplo marksman
```

## Diagnostics

Diagnostics are configured globally in `lua/features/lsp.lua`:

- Virtual text appears only for warnings and errors.
- Errors are underlined.
- Floating windows use rounded borders and sort by severity.
- Signs show a single letter per severity.

## LSP UI

- Hover and signature help use rounded borders.
- Text changes are debounced by 150 ms per server.
- No automatic popups besides completion.

## Not included

- Mason
- Java, Python, TypeScript language servers
- Debug adapters
- AI coding plugins
- Formatting plugins such as `conform.nvim` (only LSP formatting is wired)
