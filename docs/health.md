# Health checks

The configuration ships with a built-in health reporter that validates the
development environment.

## Commands

| Command | Description |
|---------|-------------|
| `:DevHealth` | Open a floating window with the full environment report. |
| `:checkhealth dev` | Use Neovim's standard `:checkhealth` integration. |

## Verified components

| Component | What is checked |
|-----------|-----------------|
| Neovim | Version >= 0.11 |
| Git | Installed and on PATH |
| ripgrep (`rg`) | Installed |
| fd | Installed |
| fzf | Installed |
| Lazygit | Installed |
| Ghostty | Installed |
| tmux | Installed |
| uv | Installed |
| JDK 8 / 11 / 17 | Homebrew or Temurin installations |
| JAVA_HOME | Environment variable points to a valid JDK |
| jdtls | Java language server binary |
| basedpyright | Python language server binary |
| ruff | Python linter / formatter binary |
| debugpy | Python debug adapter |
| google-java-format | Java formatter binary |
| Lombok | Lombok jar for annotation processing |

## Report format

Each item shows one of the following statuses:

- **✓ ok** — installed, with version when available.
- **✗ missing** — not found; the report includes a suggested install command.
- **! warning** — installed but may need attention.
- **✗ error** — misconfigured (for example, `JAVA_HOME` points to a missing
  directory).

## Suggested fixes

Most missing tools can be installed with the companion `dotfiles` repository:

```bash
cd ~/dotfiles
./install.sh
./doctor.sh
```

Or install individual tools with Homebrew:

```bash
brew install git ripgrep fd fzf lazygit tmux uv
brew install --cask ghostty temurin@8 temurin@11 temurin@17
brew install jdtls basedpyright ruff debugpy google-java-format lombok
```

For `debugpy`, the recommended path is `uv tool install debugpy` or installing
it into the active Python virtual environment.
