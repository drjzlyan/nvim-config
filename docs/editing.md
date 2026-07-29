# Editing workflow

Phase 2 adds small, focused plugins that make everyday editing smoother.

## Auto pairs (`mini.pairs`)

The following pairs are auto-completed in insert mode:

- `()`
- `[]`
- `{}`
- `<>`
- `''`
- `""`
- ` `` `

Configured in `lua/features/editing.lua`.

## Surround (`mini.surround`)

Default mappings:

| Key | Action |
|-----|--------|
| `sa` | Add surrounding pair |
| `sd` | Delete surrounding pair |
| `sr` | Replace surrounding pair |
| `sf` / `sF` | Find surrounding pair forward / backward |
| `sh` | Highlight surrounding pair |

Supports quotes, parentheses, brackets, braces, and HTML-style tags.

## Comments (built-in)

Neovim 0.10+ provides native `gc` operators — no plugin required.

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | normal | Toggle current line |
| `gc` | normal / visual | Toggle motion or selection |
| `gbc` | normal | Toggle block comment |

## TODO comments (`todo-comments.nvim`)

The following keywords are highlighted in comments:

- `TODO`
- `FIXME`
- `BUG`
- `NOTE`
- `HACK`
- `WARN`
- `PERF`

Press `<leader>st` to search all TODO comments with `fzf-lua`.
