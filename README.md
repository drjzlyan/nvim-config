# nvim-config

A custom, capability-oriented Neovim configuration built from scratch for
speed and maintainability.

## Architecture

The configuration is organized by **capability**, not by plugin:

```
nvim-config/
├── init.lua              # Entry point
├── lazy-lock.json        # Plugin lockfile
├── lua/
│   ├── core/             # Editor fundamentals
│   │   ├── options.lua   # vim options
│   │   ├── keymaps.lua   # Non-plugin keymaps
│   │   ├── autocmds.lua  # Autocommands
│   │   └── lazy.lua      # Plugin manager bootstrap
│   ├── features/         # Capability modules
│   │   ├── navigation.lua
│   │   ├── search.lua
│   │   ├── treesitter.lua
│   │   ├── editing.lua
│   │   ├── todo.lua
│   │   ├── ui.lua
│   │   ├── session.lua
│   │   ├── git.lua
│   │   └── whichkey.lua
│   ├── languages/        # Per-language configuration
│   └── util/             # Shared helpers
├── after/                # ftplugin, syntax overrides
└── docs/                 # Documentation
```

This layout makes it easy to swap plugin implementations without changing the
overall structure.

## Phases

### Phase 1 (done)

Core editing, file navigation, search, statusline, and sessions.

Plugins:

- `lazy.nvim` — plugin manager
- `which-key.nvim` — discoverable keymaps
- `snacks.nvim` — notifications, input, picker (dashboard disabled)
- `oil.nvim` — file explorer
- `fzf-lua` — search
- `lualine.nvim` — statusline
- `auto-session` — session management

### Phase 2 (done)

Editing improvements before adding language intelligence.

Plugins:

- `nvim-treesitter` + `nvim-treesitter-textobjects` — syntax, selection, text objects
- `mini.pairs` — auto-close pairs
- `mini.surround` — add/change/delete surrounding pairs
- `Comment.nvim` — `gc`/`gcc` commenting
- `todo-comments.nvim` — TODO/FIXME/etc. highlighting and search

### Phase 3 (done)

Language-aware editing with LSP, completion, and externally managed language
servers.

Plugins:

- `neovim/nvim-lspconfig` — LSP client configuration
- `saghen/blink.cmp` — completion engine
- `L3MON4D3/LuaSnip` — snippet engine
- `rafamadriz/friendly-snippets` — snippet collection

Configured language servers (installed via Homebrew):

- `lua_ls` — Lua
- `jsonls` — JSON
- `yamlls` — YAML
- `bashls` — Bash / Zsh
- `taplo` — TOML
- `marksman` — Markdown

### Phase 4 (done)

First-class Python development environment.

Tools (installed externally):

- `uv` — project runner and virtual environments
- `basedpyright` — type checking and LSP navigation
- `ruff` — linting, formatting, import organization, code actions
- `pytest` — running tests
- `debugpy` — reserved for future debugging work

See [`docs/python.md`](docs/python.md) for the full Python workflow.

### Phase 5 (done)

Production-quality Java development environment for large Maven and Gradle
projects.

Tools (installed externally):

- `openjdk@8`, `openjdk@11`, `openjdk@17` — JDKs
- `jdtls` — Java language server
- `lombok` — annotation processor (auto-configured as a Java agent)
- `google-java-format` — formatter
- `maven` — build tool
- `gradle` — build tool

See [`docs/java.md`](docs/java.md) for the full Java workflow.

### Phase 6 (done)

First-class Git experience inside Neovim.

Plugins:

- `lewis6991/gitsigns.nvim` — hunk signs, blame, preview, staging, diff
- `sindrets/diffview.nvim` — diff current changes, branches, commits, file history

External tools (managed outside Neovim):

- `git`
- `lazygit`
- `delta`

Key highlights:

- `<leader>gg` opens `lazygit` in a floating terminal (`:LazyGit`)
- `<leader>gd` opens `diffview.nvim` for the current changes
- `<leader>gh`, `<leader>gb`, `<leader>gs`, `<leader>gr`, `<leader>gn`, `<leader>gp`
  for hunk-level actions via `gitsigns.nvim`
- Git plugins lazy-load only inside Git repositories
- `which-key` registers the `<leader>g` group and all Git mappings

Recommended workflow:

1. Stage, reset, preview, and navigate hunks with the `<leader>g` mappings.
2. Open `<leader>gd` to review all current changes in a full diff view.
3. Use `:DiffviewOpen branch...HEAD` to compare against another branch.
4. Use `:DiffviewOpen <commit>` to inspect a specific commit.
5. Use `:DiffviewFileHistory %` for the history of the current file.
6. Drop into `<leader>gg` (`:LazyGit`) for branch management, rebasing, commits,
   and interactive staging.

See the sections below and [`docs/keymaps.md`](docs/keymaps.md) for the full workflow.

### Phase 7 (done)

Production-quality debugging for Python and Java.

Plugins:

- `mfussenegger/nvim-dap` — Debug Adapter Protocol client
- `rcarriga/nvim-dap-ui` — debugging UI (scopes, breakpoints, watches, call stack, REPL, console)
- `theHamsta/nvim-dap-virtual-text` — inline variable values and exceptions
- `nvim-neotest/nvim-nio` — async I/O library used by `nvim-dap-ui`
- `mfussenegger/nvim-jdtls` — jdtls DAP integration for Java (helper plugin)

External tools (managed outside Neovim):

- `debugpy`
- `java-debug`
- `java-test`

Key highlights:

- `<leader>d` group for all debugger mappings
- `<leader>db` / `<leader>dB` for breakpoints and conditional breakpoints
- `<leader>dc`, `<leader>di`, `<leader>do`, `<leader>dO` for execution control
- `<leader>du` toggles the DAP UI, `<leader>dr` opens the REPL
- DAP UI opens automatically when debugging starts and closes when it ends
- Python `debugpy` auto-detects `.venv`
- Java reuses the existing `jdtls` workspace and loads `java-debug` / `java-test` bundles

See the sections below and [`docs/keymaps.md`](docs/keymaps.md) for the full workflow.

### Phase 8 (done)

Terminal-first workflow for build, test, run, and Git operations.

Plugins:

- `akinsho/toggleterm.nvim` — persistent, reusable terminals

External tools (managed outside Neovim):

- `git`
- `maven`, `gradle` (Java)
- `uv`, `pytest` (Python)

Key highlights:

- `<leader>t` menu combines terminal and task commands
- `<leader>tt` / `<leader>tf` toggle horizontal and floating terminals
- `<leader>ta`, `<leader>tg` toggle dedicated Agent and Git terminals
- `<leader>tb`, `<leader>tr`, `<leader>ts`, `<leader>tc` run generic build, run, test, and clean tasks
- Named terminals (Shell, Build, Test, Git, Agent) are reused, never duplicated
- Generic task providers are language-agnostic; Python and Java adapters register automatically
- Project detection via `pyproject.toml`, `pom.xml`, `build.gradle`, and `settings.gradle`

See the sections below and [`docs/keymaps.md`](docs/keymaps.md) for the full workflow.

### Phase 9 (done)

Enterprise-grade Java development with testing, refactoring, call hierarchy,
and workspace management.

Tools (installed externally):

- `jdtls` — Java language server
- `java-debug` / `java-test` — test runner and debugger integration
- `google-java-format` — formatter
- `maven`, `gradle` — build tools

Key highlights:

- jdtls CodeLens enabled with automatic refresh on save and buffer enter
- JUnit 4, JUnit 5, and TestNG test runner via `nvim-jdtls`
- Test commands: nearest test, current class, package, module, re-run last,
  debug nearest, debug class
- Project commands for Maven and Gradle: compile, clean, package, install,
  test, verify
- Import helpers: organize, add missing, remove unused
- Refactoring: extract method/variable/constant, inline variable, move type,
  rename
- Call hierarchy, type hierarchy, and implementation hierarchy
- Workspace commands: build, reload, restart jdtls, clear cache, open logs
- Dedicated `which-key` groups for Java, Testing, and Workspace
- Reused jdtls workspace per project for fast startup

See [`docs/java.md`](docs/java.md) for the full Java workflow.

### Phase 10 (done)

Production-ready release: performance, reliability, documentation, health checks,
and distribution.

Focus areas:

- **Startup performance**: profiled and optimized; every plugin lazy-loads where
  appropriate; startup stays under 80 ms on Apple Silicon.
- **Health checks**: `:DevHealth` and `:checkhealth dev` verify Neovim, Git,
  ripgrep, fd, fzf, Lazygit, Ghostty, tmux, uv, JDKs, JAVA_HOME, jdtls,
  basedpyright, ruff, debugpy, google-java-format, and Lombok.
- **Project detection**: automatic root detection for Git, Python, Java, Maven,
  Gradle, and `pyproject.toml`.
- **Custom commands**: `:DevHealth`, `:DevInfo`, `:DevReload`, `:DevUpdate`,
  `:DevProfile`, `:DevCleanCache`.
- **Cache management**: clear Treesitter, JDTLS workspace, swap, sessions, and
  Lazy caches from inside Neovim.
- **Error handling**: missing executables, LSP servers, JDKs, and broken
  projects are reported gracefully; Neovim never crashes.
- **Modern APIs**: migrated LSP configuration to `vim.lsp.config` and
  `vim.lsp.enable`; no deprecated APIs.
- **Distribution**: tagged `v1.0.0`, `CHANGELOG.md`, GitHub Actions CI, and
  improved `dotfiles` scripts (`install.sh`, `update.sh`, `doctor.sh`,
  `link.sh`).

See [`docs/health.md`](docs/health.md), [`docs/troubleshooting.md`](docs/troubleshooting.md),
and [`docs/faq.md`](docs/faq.md) for details.

## Directory layout

| Path | Purpose |
|------|---------|
| `lua/core` | Options, keymaps, autocommands, lazy bootstrap |
| `lua/features` | One file per capability (navigation, search, treesitter, editing, todo, ui, session, git, debugger, terminal, tasks, testing, which-key, lsp, completion) |
| `lua/languages` | Language-specific settings, LSP configs, and debug adapters (`python.lua`, `java.lua`, `java-commands.lua`, `java-project.lua`, `java-testing.lua`, etc.) |
| `lua/util` | Shared helper functions (`helpers.lua`, `project.lua`, `java.lua`) |
| `after` | Runtime overrides such as `ftplugin` |
| `docs` | Architecture, installation, keymaps, plugins, roadmap, treesitter, editing, lsp, python, java, debugging, terminal, tasks |

## Plugin philosophy

- Every plugin must solve a specific problem.
- Avoid overlapping plugins.
- Prefer built-in Neovim features when sufficient.
- Lazy-load everything possible to keep startup under 100 ms.

## Keymap philosophy

- `<Space>` is the leader key.
- Plugin features are grouped by capability:
  - `<leader>e` — Explorer
  - `<leader>f` — Files
  - `<leader>s` — Search
  - `<leader>g` — Git
  - `<leader>q` — Session
  - `<leader>l` — LSP
  - `<leader>p` — Python
  - `<leader>j` — Java
  - `<leader>d` — Debug
  - `<leader>t` — Terminal / Tasks
- `which-key` makes every group discoverable.

## LSP architecture

LSP configuration uses Neovim 0.11's native `vim.lsp.config` and
`vim.lsp.enable` APIs. `nvim-lspconfig` is still loaded so its server
definitions are available, but the deprecated `lspconfig.*.setup()` framework
is no longer used.

LSP is split into two capability files:

- `lua/features/lsp.lua` — diagnostics, keymaps, and server enablement for
  config-file languages.
- `lua/features/completion.lua` — `blink.cmp`, `blink.lib`, `LuaSnip`, and
  snippets.

This separation keeps completion and LSP concerns independent.

## Completion architecture

`blink.cmp` provides completion from LSP, buffer text, paths, and snippets.
`LuaSnip` expands snippets and `friendly-snippets` supplies the snippet
definitions. Completion and LSP share capabilities via
`require("blink.cmp").get_lsp_capabilities()`.

## Supported language servers

Language servers and formatters are intentionally **not** managed by Mason.
Install them with Homebrew or `uv`:

| Server | Language | Package |
|--------|----------|---------|
| `lua_ls` | Lua | `lua-language-server` |
| `jsonls` | JSON | `vscode-json-languageserver` |
| `yamlls` | YAML | `yaml-language-server` |
| `bashls` | Bash / Zsh | `bash-language-server` |
| `taplo` | TOML | `taplo` |
| `marksman` | Markdown | `marksman` |
| `jdtls` | Java | `jdtls` |
| `basedpyright` | Python | `basedpyright` |
| `ruff` | Python | `ruff` |
| `google-java-format` | Java | `google-java-format` |

```bash
brew install lua-language-server vscode-json-languageserver yaml-language-server bash-language-server taplo marksman jdtls basedpyright ruff google-java-format
```

## Installation

```bash
git clone https://github.com/example/nvim-config.git ~/.config/nvim
nvim
```

`lazy.nvim` bootstraps itself and installs plugins on first launch.

## Update plugins

Run `:Lazy sync` inside Neovim or:

```bash
nvim --headless +Lazy! sync +qa
```

The `lazy-lock.json` is committed for reproducibility.

## Documentation

- [`docs/architecture.md`](docs/architecture.md)
- [`docs/installation.md`](docs/installation.md)
- [`docs/plugins.md`](docs/plugins.md)
- [`docs/keymaps.md`](docs/keymaps.md)
- [`docs/treesitter.md`](docs/treesitter.md)
- [`docs/editing.md`](docs/editing.md)
- [`docs/lsp.md`](docs/lsp.md)
- [`docs/python.md`](docs/python.md)
- [`docs/java.md`](docs/java.md)
- [`docs/debugging.md`](docs/debugging.md)
- [`docs/terminal.md`](docs/terminal.md)
- [`docs/tasks.md`](docs/tasks.md)
- [`docs/health.md`](docs/health.md)
- [`docs/troubleshooting.md`](docs/troubleshooting.md)
- [`docs/faq.md`](docs/faq.md)
- [`docs/migration.md`](docs/migration.md)
- [`docs/roadmap.md`](docs/roadmap.md)
