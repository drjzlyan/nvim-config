# Migration guide

## Migrating from a previous phase

If you have been following the phased development of this configuration, Phase
10 is a production-ready release with a few structural changes.

### LSP configuration

LSP servers are now configured with Neovim 0.11's native `vim.lsp.config` and
`vim.lsp.enable` APIs instead of `lspconfig.*.setup()`. This removes deprecation
warnings and prepares the config for future Neovim releases.

If you previously customized server settings in `lua/features/lsp.lua`,
`lua/languages/python.lua`, or `lua/languages/java.lua`, move them to the
`vim.lsp.config(name, { ... })` call for that server.

### blink.cmp dependency

Phase 10 adds `saghen/blink.lib` as an explicit dependency of `saghen/blink.cmp`.
Run `:Lazy sync` to install it.

### New commands

The following commands were added in Phase 10:

| Command | Purpose |
|---------|---------|
| `:DevHealth` | Environment health report |
| `:DevInfo` | Project detection info |
| `:DevReload` | Reload configuration modules |
| `:DevUpdate` | Update plugins and tooling |
| `:DevProfile` | Profile startup |
| `:DevCleanCache` | Clear caches |

### dotfiles scripts

The companion `dotfiles` repository gained improved idempotency and safety:

- `install.sh` — safe to re-run on a fresh or existing macOS install.
- `update.sh` — updates Homebrew packages and `uv`.
- `doctor.sh` — verifies tools and symlinks.
- `link.sh` — backs up existing files before symlinking.

### Versioning

The project is tagged `v1.0.0`. See `CHANGELOG.md` for the release notes.

## Migrating from another Neovim distribution

1. Back up your existing config: `mv ~/.config/nvim ~/.config/nvim.bak`.
2. Clone this repository: `git clone <repo> ~/.config/nvim`.
3. Install required tools with the `dotfiles` repository or Homebrew.
4. Run `nvim` and let lazy.nvim install plugins.
5. Run `:DevHealth` to verify the environment.
