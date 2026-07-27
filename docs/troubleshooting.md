# Troubleshooting

## General approach

1. Run `:DevHealth` to verify the environment.
2. Run `:checkhealth dev` for the standard Neovim health report.
3. Check `:messages` for recent errors.
4. Profile startup with `:DevProfile`.

## Startup is slow

Run `:DevProfile` to generate a startup log. The target is under 80 ms on
Apple Silicon. Common causes:

- A plugin marked `lazy = false` that could be event-loaded.
- A heavy language server configured to attach eagerly.
- Large sessions being restored by `auto-session`.

If startup exceeds the target, review the profile log and move heavy plugins to
later events.

## Language server does not attach

1. Verify the server binary is installed (`:DevHealth`).
2. Check the project root with `:DevInfo`.
3. Look for LSP errors in `:messages`.
4. For Java, inspect the JDTLS workspace log with `<leader>jl` or
   `:JavaOpenWorkspaceLogs`.

## Java projects

### JDTLS fails to start

- Ensure a JDK is installed and `JAVA_HOME` is set (`:DevHealth`).
- Delete the JDTLS workspace cache with `:JavaClearWorkspaceCache` or
  `:DevCleanCache jdtls`.
- Verify `jdtls` is on PATH and executable.

### Lombok annotations are not resolved

- Confirm Lombok is installed (`:DevHealth`).
- The configuration automatically adds Lombok as a Java agent when the jar is
  found.

### Build commands fail

- Check that `mvn` or `gradle` is installed and the project root is detected
  (`:DevInfo`).
- Build output appears in the dedicated `build` terminal (`<leader>tb`).

## Python projects

### basedpyright reports wrong Python version

- basedpyright is notified of the active virtual environment after attach.
- Ensure a `.venv` or `venv` directory exists at the project root, or set
  `VIRTUAL_ENV`.

### Ruff formatting or imports are not applied

- Ruff must be installed (`:DevHealth`).
- Format-on-save is triggered by `BufWritePre`; check `:messages` for errors.

### debugpy is not found

- Install debugpy with `uv tool install debugpy` or into the project venv with
  `pip install debugpy`.

## Git

### Git plugins do not load

- Git-related plugins lazy-load only inside a Git repository.
- Run `:DevInfo` to confirm `.git` was detected.

### Lazygit fails to open

- Verify `lazygit` is installed (`:DevHealth`).
- Ensure you are inside a Git repository.

## Caches

Use `:DevCleanCache` to clear:

- `treesitter` — Treesitter parser cache.
- `jdtls` — JDTLS workspace data.
- `swap` — Swap files (mostly unused because `swapfile = false`).
- `sessions` — auto-session session files.
- `lazy` — Lazy.nvim plugin cache (`Lazy clean`).
- `all` — all of the above (default).

## Still stuck?

Open a terminal with `<leader>tt` and run the failing command directly to see
raw output. Most task runners send commands to named terminals so errors are
visible.
