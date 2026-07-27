# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-27

### Added

- Startup profiling target of < 80 ms on Apple Silicon.
- `:DevHealth` command and `:checkhealth dev` integration for environment
  validation.
- `:DevInfo` command for project root and type detection.
- `:DevReload`, `:DevUpdate`, `:DevProfile`, and `:DevCleanCache` commands.
- Cache management for Treesitter, JDTLS workspace, swap files, sessions, and
  Lazy.nvim.
- Graceful error handling for missing executables, LSP servers, JDKs, and
  broken projects.
- `saghen/blink.lib` as an explicit dependency of `saghen/blink.cmp`.
- GitHub Actions CI workflow for stylua, luacheck, Neovim startup, and plugin
  installation.
- Comprehensive documentation: health checks, troubleshooting, FAQ, and
  migration guides.

### Changed

- Migrated LSP configuration from `lspconfig.*.setup()` to Neovim 0.11's
  `vim.lsp.config` and `vim.lsp.enable` APIs.
- Optimized lazy-loading for `snacks.nvim` and deferred Python/Java LSP setup
  to filetype events.
- Improved `dotfiles` scripts (`install.sh`, `update.sh`, `doctor.sh`,
  `link.sh`) for idempotent execution and fresh macOS installs.
- Updated `Brewfile` to include Java and Python language tooling.

### Fixed

- Resolved `blink.cmp` loading issues by adding the required `blink.lib`
  dependency.
- Removed usage of deprecated `vim.lsp.with()` and `lspconfig` setup framework.
- Hardened external command and file-system calls against failures.
