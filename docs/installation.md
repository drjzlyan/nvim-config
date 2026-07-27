# Installation

## Requirements

- macOS
- Neovim >= 0.11
- Git
- A Nerd Font (installed by the `dotfiles` repo)

## Bootstrap

```bash
git clone https://github.com/example/nvim-config.git ~/.config/nvim
nvim
```

On first launch:

1. `lazy.nvim` clones itself into `~/.local/share/nvim/lazy/lazy.nvim`.
2. `lazy.nvim` installs all Phase 1 plugins.
3. `lazy-lock.json` is created/updated.

## First-time dotfiles setup

If you are using the companion `dotfiles` repository:

```bash
cd dotfiles
./install.sh
./link.sh
```

This installs the required tools and fonts.

## Language servers

Phase 3 uses `nvim-lspconfig` with language servers managed externally by
Homebrew. Mason is intentionally not used.

Install the supported servers:

```bash
brew install lua-language-server vscode-json-languageserver yaml-language-server bash-language-server taplo marksman
```

Verify each binary is on your `$PATH` before opening the corresponding
filetype.

## Verify startup time

```bash
nvim --startuptime /tmp/startup.log -c "q"
tail -5 /tmp/startup.log
```

The target is under 80 ms on Apple Silicon. Inside Neovim you can also run
`:DevProfile`.

## Verify the environment

After installation, run:

```vim
:DevHealth
```

or

```vim
:checkhealth dev
```

Install any missing tools reported by the health check.

## Update plugins

Inside Neovim:

```vim
:Lazy sync
```

From the terminal:

```bash
nvim --headless +Lazy! sync +qa
```

Commit the updated `lazy-lock.json` to keep environments reproducible.
