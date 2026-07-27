# Keymaps

Leader: `<Space>`

## Global

| Key | Mode | Action |
|-----|------|--------|
| `<Esc>` | n | Clear search highlight |
| `<leader>W` | n | Save |
| `<leader>Z` | n | Quit |
| `<leader>c` | n | Close buffer |
| `<leader>-` | n | Split below |
| `<leader>\|` | n | Split right |
| `<leader>=` | n | Equalize splits |
| `<C-h/j/k/l>` | n | Navigate windows |
| `<A-j/k>` | n/v | Move line(s) |

## Explorer (`oil.nvim`)

| Key | Action |
|-----|--------|
| `<leader>e` | Open oil at current file's directory |
| `<leader>E` | Open oil at working directory |

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

## Session (`auto-session`)

Sessions are saved/restored automatically per project. Manual commands:

| Command | Action |
|---------|--------|
| `:SessionSave` | Save current session |
| `:SessionRestore` | Restore session for cwd |
| `:SessionDelete` | Delete current session |

## Discoverability

Press `<leader>` and pause to see groups via `which-key.nvim`.

Reserved groups for later phases:

- `<leader>d` — Debug
- `<leader>t` — Terminal
