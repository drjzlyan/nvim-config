# Frequently asked questions

## Why is Mason not used?

Language servers and formatters are intentionally managed outside Neovim using
Homebrew and `uv`. This keeps editor configuration portable and reproducible
across machines.

## How do I install the required tools?

Use the companion `dotfiles` repository:

```bash
cd ~/dotfiles
./install.sh
./link.sh
./doctor.sh
```

## Can I use this on Linux or Windows?

The configuration is developed and tested on macOS. Linux should work with
minor path adjustments. Windows is not officially supported.

## Why does `:DevReload` say plugin specs require a restart?

lazy.nvim manages plugin specs during startup. Re-sourcing `init.lua` reloads
custom modules and options but cannot change plugin specifications. Restart
Neovim to apply plugin changes.

## How do I update plugins?

Run `:Lazy sync` inside Neovim, or use the `:DevUpdate` command which also
updates external tooling through `~/dotfiles/update.sh` when available.

## How do I profile startup?

Run `:DevProfile` or from a shell:

```bash
nvim --startuptime /tmp/startup.log -c "q"
tail -20 /tmp/startup.log
```

## Where are sessions stored?

Sessions are managed by `auto-session` in `~/.local/share/nvim/sessions/`.

## Why are some LSP features missing?

Ensure the language server is installed and detected by `:DevHealth`. Also
verify the project root with `:DevInfo`.

## How do I add a new language server?

1. Install the server binary with Homebrew or `uv`.
2. Add a `vim.lsp.config(name, { ... })` and `vim.lsp.enable(name)` call in the
   appropriate language module under `lua/languages/`.
3. Run `:DevReload` or restart Neovim.

## What is the difference between `:DevHealth` and `:checkhealth dev`?

`:DevHealth` opens a focused floating report. `:checkhealth dev` uses Neovim's
built-in `:checkhealth` system and is easier to capture in CI.
