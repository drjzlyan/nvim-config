# Languages

The IDE supports configurable per-language development environments with
runtime version selection. Users choose which languages to set up and which
versions to install during installation, and can add, remove, or change
versions at any time without affecting existing settings.

## How language selection works

1. The user runs `dotfiles/scripts/languages.sh` (automatically launched
   during `install.sh` on first setup).
2. The script writes the selection to `~/.local/share/nvim/languages.local`
   in `key=value` format (one language + version per line).
3. The script generates `dotfiles/mise.toml` from the selection and runs
   `mise install` to install the chosen runtime versions.
4. `nvim-config/lua/languages/init.lua` reads that file at startup and
   conditionally loads the matching module under `lua/languages/`.
5. `scripts/install-tools.sh` reads the same file and installs only the
   external tools for the selected languages.

This design means:
- **Non-destructive**: existing settings are never modified. The selection
  file is separate from all configuration.
- **Dynamic versions**: versions are queried from `mise ls-remote` at
  selection time — no static version lists are stored anywhere.
- **Idempotent**: re-running the selector preserves existing choices.
- **Extensible**: new languages can be added by creating a new module in
  `lua/languages/` and an entry in the selector script.

## Selecting languages and versions

```bash
# Interactive menu (toggle languages by number, 'v' to change version)
~/Development/dotfiles/scripts/languages.sh

# Select all languages and install tools
~/Development/dotfiles/scripts/languages.sh --all

# Show current selection
~/Development/dotfiles/scripts/languages.sh --list
```

After changing the selection, restart Neovim for the new language modules to
load. The `install-tools.sh` script runs automatically after selection to
install any missing external tools.

## Always-available languages

These common/config languages are always enabled regardless of the selection.
Their LSP servers are configured in `lua/features/lsp.lua`:

| Language | LSP server | Install |
|----------|-----------|---------|
| Lua | `lua_ls` | `brew install lua-language-server` |
| JSON | `jsonls` | `brew install vscode-json-languageserver` |
| YAML | `yamlls` | `brew install yaml-language-server` |
| Bash / Zsh | `bashls` | `brew install bash-language-server` |
| TOML | `taplo` | `brew install taplo` |
| Markdown | `marksman` | `brew install marksman` |

Install all at once:

```bash
brew install lua-language-server vscode-json-languageserver yaml-language-server \
  bash-language-server taplo marksman
```

## Selectable languages

### Python

- **LSP**: `basedpyright` (type checking, navigation, hover), `ruff` (linting,
  formatting, import organization, code actions)
- **Debugger**: `debugpy` (via DAP)
- **Formatter**: Ruff (format + organize imports on save)
- **Test runner**: pytest (`<leader>pt`, `<leader>ptf`, `<leader>ptp`)
- **Runtime**: managed by `mise` (Python 3.12)
- **Treesitter**: `python`, `requirements`

Keymaps: `<leader>p` group (see [python.md](python.md) for full reference).

Tools installed by `install-tools.sh`:
```
uv tool install basedpyright
uv tool install ruff
```

### Java

- **LSP**: `jdtls` (Eclipse Java Language Server)
- **Debugger**: `java-debug` + `java-test` bundles (via DAP)
- **Formatter**: `google-java-format` (via `conform.nvim`, on save)
- **Test runner**: JUnit 4, JUnit 5, TestNG (`<leader>jt`, `<leader>jT`)
- **Runtime**: JDK 8, 11, 17 (managed by `mise`)
- **Lombok**: auto-configured as a Java agent
- **Treesitter**: `java`

Keymaps: `<leader>j` and `<leader>W` groups (see [java.md](java.md) for full
reference).

### TypeScript / JavaScript

- **LSP**: `typescript-language-server` (powered by `tsserver`)
- **Formatter**: `prettier` (format on save for `.ts`, `.tsx`, `.js`, `.jsx`)
- **Treesitter**: `typescript`, `tsx`, `javascript`
- **Runtime**: Node.js 20 (managed by `mise`)

File types: `typescript`, `typescriptreact`, `javascript`, `javascriptreact`.

The LSP server attaches automatically when a TypeScript or JavaScript file is
opened. Root detection uses `tsconfig.json` or `package.json`.

Formatting on save uses `prettier` if available. The shared `<leader>lf` keymap
also works.

Build artifacts (`node_modules/`, `dist/`, `build/`) are excluded from search.

Tools installed by `install-tools.sh`:
```
npm install -g typescript-language-server typescript prettier
```

### Go

- **LSP**: `gopls` (Go language server)
- **Import organizer**: `goimports` (on save via `gopls` code action)
- **Debugger**: `delve` via DAP (four launch configs: debug file, debug package, debug test, attach to process — see [debugging.md](debugging.md#go-debugging))
- **Formatter**: `gofmt` / `goimports` (format on save via `gopls`)
- **Treesitter**: `go`, `gomod`, `gosum`
- **Runtime**: Go 1.23 (managed by `mise`)

File types: `go`, `gomod`, `gowork`, `gotmpl`.

Root detection uses `go.mod` or `go.work`.

Format on save runs `goimports` (organize imports) then `gofmt` via `gopls`.
The `<leader>lI` keymap manually triggers import organization.

The generic task provider dispatches to `go build`, `go test`, `go run`, and
`go clean` when a Go project is detected.

Tools installed by `install-tools.sh`:
```
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/go-delve/delve@latest
```

### C / C++

- **LSP**: `clangd` (with clang-tidy, background indexing, header insertion)
- **Formatter**: `clang-format` (format on save, LLVM fallback style)
- **Treesitter**: `cpp`, `c`

File types: `c`, `cpp`, `objc`, `objcpp`, `cuda`.

Root detection uses `compile_commands.json`, `CMakeLists.txt`, `Makefile`, or
`meson.build`.

`clangd` is configured with:
- Background indexing
- clang-tidy diagnostics
- Header insertion (iwyu style)
- Function argument placeholders in completion

Build artifacts (`build/`, `cmake-build-*/`, `.cache/`) are excluded from search.

Tools installed by `install-tools.sh`:
```
brew install clangd
```

### Rust

- **LSP**: `rust-analyzer` (with clippy checks, cargo integration)
- **Formatter**: `rustfmt` (format on save via `rust-analyzer`)
- **Treesitter**: `rust`
- **Runtime**: Rust 1.81 (managed by `mise`)

File types: `rust`.

Root detection uses `Cargo.toml`.

`rust-analyzer` is configured with:
- All cargo features enabled
- Clippy on save
- Proc macro support
- Inlay hints (type hints, parameter hints, chaining hints)

Build artifacts (`target/`) are excluded from search.

The generic task provider dispatches to `cargo build`, `cargo test`,
`cargo run`, and `cargo clean` when a Rust project is detected.

Tools installed by `install-tools.sh`:
```
rustup component add rust-analyzer
```

(Falls back to `brew install rust-analyzer` if `rustup` is not available.)

## Adding a new language

1. Create `lua/languages/<name>.lua` following the pattern of the existing
   modules (see `go.lua` for a clean example):
   - Check for required executables before enabling LSP
   - Set up `FileType` autocmd for the language
   - Set up `BufWritePre` autocmd for format-on-save
   - Add to `wildignore` for build artifact directories
   - Optionally register a task provider
   - Return `{}`

2. Add an entry to `ALL_LANGUAGES` in `dotfiles/scripts/languages.sh`:
   ```
   "name:Display Name:mise_tool:default_version"
   ```
   Use `none` as the mise_tool if the language has no mise-managed runtime.

3. Add the language name to `M.available` in `lua/languages/init.lua`.

4. Add treesitter parsers to `lang_parsers` in `lua/features/treesitter.lua`.

5. Add install logic to `scripts/install-tools.sh` under a
   `if has_language "name"; then ... fi` block. Use `get_version "name"`
   to read the user's selected version if applicable.

6. Add a check case to `check_language_tools()` in `dotfiles/doctor.sh`.

7. If the language has a mise-managed runtime, add it to the
   `generate_mise_toml()` function in `languages.sh`.

8. Document the language in this file.

## Configuration file format

`~/.local/share/nvim/languages.local`:

```
# Languages and versions configured for this machine.
# Generated by dotfiles/scripts/languages.sh
# Format: language=version (or language=version1,version2,... for multi-version)
# Edit manually or re-run the selector to change.

python=3.12.7
java=25,21,17
typescript=20.18.0
go=1.23.3
cpp=system
rust=1.81.0
```

Lines starting with `#` are comments. Blank lines are ignored. Each
non-comment line is `language=version` where:
- `language` matches a module in `lua/languages/`
- `version` is the runtime version installed by `mise` (or `system` for
  languages that use the system compiler like C/C++ with clangd)
- **Multiple versions** can be specified as a comma-separated list
  (`java=25,21,17`). The first version is the primary (default) runtime; the
  rest are installed alongside it. This is useful for Java, where you may need
  to switch between LTS releases with `mise use java@<version>`.

The `mise.toml` file in the dotfiles repo is **generated** from this
selection — do not edit it manually. Re-run the language selector to
regenerate it.
