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

- `<leader>l` — LSP
- `<leader>d` — Debug
- `<leader>t` — Terminal
- `<leader>q` — Session
