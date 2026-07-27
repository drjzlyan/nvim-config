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

## Phase 5 — Java development environment (done)

- [x] Java treesitter parser
- [x] `jdtls` LSP (definition, references, rename, hover, implementation, type definition, workspace symbols, document symbols, call hierarchy, code actions)
- [x] JDK auto-detection (8, 11, 17) with `JAVA_HOME` respect
- [x] Lombok auto-configuration via Homebrew
- [x] `google-java-format` formatting via `conform.nvim`
- [x] Format on save for Java
- [x] Maven and Gradle project detection
- [x] Java keymaps and which-key group

See [`docs/java.md`](docs/java.md) for details.

## Phase 6 — Git integration (done)

- [x] Hunk signs, blame, preview, staging, and diff (`gitsigns.nvim`)
- [x] Diff current changes, branches, commits, and file history (`diffview.nvim`)
- [x] Floating LazyGit terminal (`:LazyGit`)
- [x] Lazy-load Git plugins only inside Git repositories
- [x] Git keymaps and `which-key` group

See `docs/plugins.md` and `docs/keymaps.md` for details.

## Phase 7 — Debugging (done)

- [x] DAP client, UI, virtual text, and REPL (`nvim-dap`, `nvim-dap-ui`, `nvim-dap-virtual-text`)
- [x] Python debugging via `debugpy`
- [x] Java debugging via `java-debug` / `java-test` through existing `jdtls`
- [x] Breakpoints, conditional breakpoints, logpoints, and clear breakpoints
- [x] Debugger keymaps and `which-key` group

See `docs/plugins.md` and `docs/keymaps.md` for details.

## Phase 8 — Terminal-first workflow (done)

- [x] `akinsho/toggleterm.nvim` for persistent, reusable terminals
- [x] Horizontal, vertical, and floating terminal layouts
- [x] Dedicated terminals: Shell, Build, Test, Git, Agent
- [x] Generic task commands (build, test, run current file, run project, clean)
- [x] Language-agnostic task providers with Python and Java adapters
- [x] Project detection via `pyproject.toml`, `pom.xml`, `build.gradle`, and `settings.gradle`
- [x] Terminal and task keymaps under `<leader>t`
- [x] `which-key` registration for terminal and task commands

See [`docs/terminal.md`](docs/terminal.md) and [`docs/tasks.md`](docs/tasks.md) for details.

## Phase 9 — Enterprise Java (done)

- [x] jdtls CodeLens enabled and refreshed on save / buffer enter
- [x] Generic testing layer (`lua/features/testing.lua`) with Java adapter
- [x] Test runner support for JUnit 4, JUnit 5, and TestNG
- [x] Test commands: nearest, current class, package, module, re-run last,
  debug nearest, debug class
- [x] Maven and Gradle project commands: compile, clean, package, install,
  test, verify
- [x] Import helpers: organize, add missing, remove unused
- [x] Refactoring commands: extract method/variable/constant, inline variable,
  move type, rename
- [x] Call hierarchy, type hierarchy, implementation hierarchy
- [x] Workspace commands: build, reload, restart jdtls, clear cache, open logs
- [x] `which-key` groups for Java, Testing, and Workspace
- [x] Reused jdtls workspace and cached project metadata

See [`docs/java.md`](docs/java.md) for details.

## Non-goals

- Re-implementing LazyVim, NvChad, AstroNvim, or Kickstart.
- Adding plugins that overlap with existing capabilities.
- Coupling the editor to coding agents.
