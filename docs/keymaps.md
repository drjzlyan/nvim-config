# Keymaps

Leader: `<Space>`

## Global

| Key | Mode | Action |
|-----|------|--------|
| `<Esc>` | n | Clear search highlight |
| `<leader>S` | n | Save |
| `<leader>Z` | n | Quit |
| `<leader>c` | n | Close buffer |
| `<leader>-` | n | Split below |
| `<leader>\|` | n | Split right |
| `<leader>=` | n | Equalize splits |
| `<C-h/j/k/l>` | n | Navigate windows |
| `<A-j/k>` | n/v | Move line(s) |
| `<` / `>` | v | Indent left / right (selection stays active) |

## Diagnostics (`trouble.nvim`)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ee` | n | Diagnostics list |
| `<leader>er` | n | LSP references (Trouble) |
| `<leader>ei` | n | LSP implementations (Trouble) |
| `<leader>en` | n | Next trouble item |
| `<leader>ep` | n | Previous trouble item |

## Explorer (`oil.nvim`)

| Key | Action |
|-----|--------|
| `<leader>E` | Open oil at current file's directory |
| `<leader>O` | Open oil at working directory |

Inside an oil buffer:

| Key | Action |
|-----|--------|
| `q` | Close oil |
| `<C-s>` | Open file in horizontal split |
| `<C-v>` | Open file in vertical split |

## Files (`fzf-lua`)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |

## Search (`fzf-lua`)

| Key | Action |
|-----|--------|
| `<leader>:` | Command history |
| `<leader><space>` | Buffers |
| `<leader>s/` | Live grep |
| `<leader>s*` | Grep word under cursor |

## Incremental selection (treesitter)

| Key | Mode | Action |
|-----|------|--------|
| `gnn` | n | Init selection |
| `grn` | n | Node increment |
| `grm` | n | Scope increment |
| `grc` | n | Node decrement |

## Text objects (treesitter)

| Key | Action |
|-----|--------|
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `ab` / `ib` | Around / inside block |
| `ap` / `ip` | Around / inside parameter |
| `]f` / `[f` | Next / previous function |
| `]c` / `[c` | Next / previous class |
| `]b` / `[b` | Next / previous block |
| `]p` / `[p` | Next / previous parameter |
| `]F` / `[F` | Next / previous function end |
| `]C` / `[C` | Next / previous class end |
| `]B` / `[B` | Next / previous block end |
| `]P` / `[P` | Next / previous parameter end |

## Comments

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | n | Toggle current line |
| `gc` | n/v | Toggle selection / motion |
| `gbc` | n | Toggle block comment |

## Surround (mini.surround)

| Key | Mode | Action |
|-----|------|--------|
| `sa` | n/v | Add surround |
| `sd` | n | Delete surround |
| `sr` | n | Replace surround |
| `sf` / `sF` | n | Find surround forward/backward |
| `sh` | n | Highlight surround |

## TODO comments

| Key | Action |
|-----|--------|
| `<leader>st` | Search TODO/FIXME/etc. |

## LSP

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gr` | n | Find references |
| `gi` | n | Go to implementation |
| `gt` | n | Go to type definition |

### Documentation

| Key | Mode | Action |
|-----|------|--------|
| `K` | n | Hover documentation |
| `<C-k>` | i | Signature help |

### Actions (`<leader>l`)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>lr` | n | Rename symbol |
| `<leader>la` | n/v | Code action |
| `<leader>lf` | n/v | Format with LSP |
| `<leader>ls` | n | Workspace symbols |
| `<leader>ld` | n | Document symbols |

## Python

Python keymaps are active only in Python buffers.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pr` | n | Run current file |
| `<leader>pm` | n | Run current module |
| `<leader>ps` | v | Run selected code |
| `<leader>pt` | n | pytest current file |
| `<leader>ptf` | n | pytest current function / method |
| `<leader>ptp` | n | pytest whole project |
| `<leader>pi` | n | Organize imports |
| `<leader>pf` | n / v | Format with Ruff |
| `<leader>pv` | n | Show active virtual environment |

## Java

Java keymaps are active only in Java buffers.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>jf` | n / v | Format with google-java-format |
| `<leader>ji` | n | Organize imports |
| `<leader>jr` | n / v | Refactor menu |
| `<leader>jc` | n | Compile project |
| `<leader>jp` | n | Package project |
| `<leader>jv` | n | Verify project |
| `<leader>jt` | n | Run nearest test |
| `<leader>jT` | n | Run test class |
| `<leader>jd` | n | Debug nearest test |
| `<leader>jD` | n | Debug test class |
| `<leader>jh` | n | Call / type hierarchy |
| `<leader>jl` | n | Workspace logs |
| `<leader>jw` | n | Restart workspace |

## TypeScript / JavaScript

No dedicated keymaps; use the shared LSP keys (`gd`, `gr`, `K`, `<leader>la`,
`<leader>lr`, `<leader>lf`). Format on save runs automatically via `prettier`.

## Go

Go keymaps are active only in Go buffers.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>lI` | n | Organize imports (goimports) |

Format on save runs `goimports` + `gofmt` automatically via `gopls`. Use
`<leader>lf` for manual formatting.

## C / C++

No dedicated keymaps; use the shared LSP keys. Format on save runs
`clang-format` automatically via `clangd`.

## Rust

No dedicated keymaps; use the shared LSP keys. Format on save runs `rustfmt`
automatically via `rust-analyzer`.

## Debug (`nvim-dap`)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Conditional breakpoint |
| `<leader>dc` | n | Continue / start debugging |
| `<leader>di` | n | Step into |
| `<leader>do` | n | Step over |
| `<leader>dO` | n | Step out |
| `<leader>dr` | n | Open REPL |
| `<leader>du` | n | Toggle DAP UI |
| `<leader>dt` | n | Terminate session |
| `<leader>dx` | n | Clear all breakpoints |

The debugger loads only when a debug keymap or command is used.

## Git

Git keymaps are active only inside Git repositories.

Lazygit opens in a dedicated tmux window via `Ctrl-a g` (not inside Neovim).
Use hunk-level keys below for in-editor work; use `<leader>gd` to review the
full diff before switching to lazygit to commit.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gd` | n | Open Diffview (current changes) |
| `<leader>gh` | n | Preview hunk |
| `<leader>gb` | n | Blame current line |
| `<leader>gs` | n / v | Stage hunk |
| `<leader>gr` | n / v | Reset hunk |
| `<leader>gu` | n | Undo stage hunk |
| `<leader>gn` | n | Next hunk |
| `<leader>gp` | n | Previous hunk |
| `<leader>gD` | n | Diff against index |

See `docs/roadmap.md` and `docs/plugins.md` for the full Git workflow.

## Session (`auto-session`)

Sessions are saved/restored automatically per project. Manual commands:

| Command | Action |
|---------|--------|
| `:SessionSave` | Save current session |
| `:SessionRestore` | Restore session for cwd |
| `:SessionDelete` | Delete current session |

## Discoverability

Press `<leader>` and pause to see groups via `which-key.nvim`.

## Testing

Testing keymaps are generic and work in any buffer supported by a registered
test provider.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Tt` | n | Run nearest test |
| `<leader>Tc` | n | Run test class |
| `<leader>Tp` | n | Run package tests |
| `<leader>Tm` | n | Run module tests |
| `<leader>Tl` | n | Re-run last test |
| `<leader>Td` | n | Debug nearest test |
| `<leader>TD` | n | Debug test class |

## Workspace

Workspace keymaps are Java-specific and manage the jdtls workspace.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Wb` | n | Build workspace |
| `<leader>Wr` | n | Reload workspace configuration |
| `<leader>Ww` | n | Restart jdtls |
| `<leader>Wc` | n | Clear workspace cache |
| `<leader>Wl` | n | Open workspace logs |

## Terminal

| Key | Action |
|-----|--------|
| `<leader>t` | Focus tmux build/test pane (floating terminal outside tmux) |

## Make / Tasks (`<leader>m`)

Generic task commands dispatched through the language provider detected for the
current buffer. Falls back to `just` or `make` if no provider matches.

| Key | Action |
|-----|--------|
| `<leader>mb` | Run build task |
| `<leader>ms` | Run test task |
| `<leader>mc` | Run clean task |
| `<leader>mp` | Run project task |

## Developer commands

These commands are not bound to keys by default.

| Command | Action |
|---------|--------|
| `:DevHealth` | Show environment health report |
| `:DevInfo` | Show project detection info for the current buffer |
| `:DevReload` | Reload configuration modules |
| `:DevUpdate` | Update plugins and external tooling |
| `:DevProfile` | Profile Neovim startup |
| `:DevCleanCache [target]` | Clear one or more caches — `treesitter`, `jdtls`, `swap`, `sessions`, `lazy`, or `all` |

Examples: `:DevCleanCache jdtls`, `:DevCleanCache treesitter sessions`, `:DevCleanCache all`.
