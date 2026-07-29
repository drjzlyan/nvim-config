# Treesitter

Treesitter powers syntax highlighting, indentation, incremental selection, and
smart text objects without needing LSP.

## Installed parsers

Only the parsers needed for configuration and general editing are installed:

- `lua`
- `vim` / `vimdoc`
- `bash`
- `markdown` / `markdown_inline`
- `json`
- `yaml`
- `toml`
- `dockerfile`
- `gitignore`

Language-specific parsers are loaded dynamically at startup from
`lua/features/treesitter.lua` based on the languages selected in
`~/.local/share/nvim/languages.local`. Selecting Python, Java, TypeScript, Go,
C/C++, or Rust automatically adds the corresponding parsers (e.g. `python`,
`java`, `typescript`, `tsx`, `javascript`, `go`, `gomod`, `gosum`, `cpp`, `c`,
`rust`).

## Treesitter context

`nvim-treesitter-context` pins a sticky header at the top of the buffer showing
the function, class, or block the cursor is currently inside. Up to 3 context
lines are shown (`max_lines = 3`). This has no keymaps — it updates
automatically as you scroll.

## Incremental selection

| Key | Action |
|-----|--------|
| `gnn` | Start selection on current node |
| `grn` | Expand to next node |
| `grm` | Expand to surrounding scope |
| `grc` | Shrink selection to previous node |

## Text objects

All text objects support `a` (around) and `i` (inside):

| Key | Target |
|-----|--------|
| `f` | Function |
| `c` | Class / type |
| `b` | Block |
| `p` | Parameter / argument |

Motion jumps (`[` / `]`) are also provided for each target, with lowercase for
starts and uppercase for ends.

## Configuration

Configured in `lua/features/treesitter.lua`.
