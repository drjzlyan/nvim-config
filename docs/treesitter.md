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

Language-specific parsers (Java, Python, TypeScript, etc.) will be added in
Phase 3.

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
