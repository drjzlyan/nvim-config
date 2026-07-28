# Tutorial: Using the IDE

A hands-on, keystroke-by-keystroke walkthrough for the `dotfiles` + `nvim-config`
development environment. Unlike the reference docs, this guide is sequenced: follow
it top to bottom and you will have selected languages, edited, built, tested,
debugged, and committed code in Python and Java, and managed a repository with
lazygit.

Prerequisites:

- macOS (Apple Silicon or Intel)
- Git
- Internet connection

Conventions used below:

- `<leader>` means the `Space` key.
- `n` / `i` / `v` after a key means Normal / Insert / Visual mode.
- `:Foo` means type the command then press `Enter`.
- Press `<Esc>` to return to Normal mode after any Insert action.

---

## Part 1 — Set up and learn the IDE

This part bootstraps the machine and teaches the core editing movements you will
reuse in every later part.

### 1.1 Bootstrap the machine

The `dotfiles` repo installs package managers, tools, fonts, and JVMs and
symlinks shell/tmux/git configuration into `$HOME`. It contains no editor
configuration — that lives in `nvim-config`.

```bash
git clone git@github.com:drjzlyan/devenv-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh     # installs Homebrew packages + casks from the Brewfile (idempotent)
./link.sh        # symlinks .zshrc, .tmux.conf, .gitconfig, starship.toml, … into $HOME
```

What you get (from the Brewfile):

- Editor: `neovim`
- Shell: `zsh`, `starship`, `direnv`, `zoxide`
- Multiplexer + terminal: `tmux`, Ghostty (cask)
- Search & navigation: `ripgrep`, `fd`, `fzf`, `bat`
- Git tooling: `git`, `lazygit`, `git-delta`
- Runtime managers: `mise`, `uv`
- Nerd Font: `font-jetbrains-mono-nerd-font`

Add your Git identity (the repo leaves this to you):

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
    name = Your Name
    email = you@example.com
EOF
```

Restart your terminal (or `source ~/.zshrc`) so the new prompt and `$PATH` apply.

### 1.2 Install the editor configuration

```bash
git clone git@github.com:drjzlyan/nvim-config.git ~/.config/nvim
nvim
```

On first launch `lazy.nvim` bootstraps itself, installs all plugins, and writes
`lazy-lock.json`. Wait for the notifications to finish.

### 1.3 Select programming languages

`install.sh` launches an interactive language selector after the editor config
is linked. Choose the languages you want — the IDE and tool installer adapt
automatically:

```
  ╔═══════════════════════════════════════════════════════════╗
  ║          Language Selection for Neovim IDE                ║
  ╠═══════════════════════════════════════════════════════════╣
  ║  Common languages are always available:                   ║
  ║    JSON, YAML, Bash, Lua, TOML, Markdown                  ║
  ╠═══════════════════════════════════════════════════════════╣
  ║  Toggle languages by number. Press Enter when done.      ║
  ╚═══════════════════════════════════════════════════════════╝

  [✓] 1. python       Python — basedpyright, ruff, pytest, debugpy
  [ ] 2. java        Java — jdtls, lombok, google-java-format, Maven/Gradle, JUnit
  [ ] 3. typescript  TypeScript/JS — typescript-language-server, prettier
  [ ] 4. go          Go — gopls, goimports, delve
  [ ] 5. cpp         C/C++ — clangd, clang-format
  [ ] 6. rust        Rust — rust-analyzer, rustfmt, cargo
```

Common languages (JSON, YAML, Bash, Lua, TOML, Markdown) are **always
available** — you don't select them.

To add or remove languages later (without re-running the full installer):

```bash
~/Development/dotfiles/scripts/languages.sh          # interactive menu
~/Development/dotfiles/scripts/languages.sh --list   # show current selection
~/Development/dotfiles/scripts/languages.sh --all     # select all + install tools
```

The selection is saved to `~/.local/share/nvim/languages.local` and is
non-destructive — your existing settings are never modified. After changing
the selection, restart Neovim and the new language modules load automatically.

See [`docs/languages.md`](languages.md) for the full list of tools and
keymaps per language.

### 1.4 Verify the environment

Inside Neovim run the health check:

```vim
:DevHealth
```

It verifies Neovim, Git, ripgrep, fd, fzf, lazygit, Ghostty, tmux, uv, the JDKs,
`JAVA_HOME`, jdtls, basedpyright, ruff, debugpy, google-java-format, and Lombok.
Install anything it reports as missing, then re-run.

Also useful:

```vim
:DevInfo       " what project/root was detected for this buffer
:DevProfile    " profile startup (target: under 80 ms on Apple Silicon)
```

### 1.5 Core movements you will use everywhere

Open any file (we'll make a scratch one):

```bash
mkdir -p ~/ide-tutorial && cd ~/ide-tutorial && nvim hello.txt
```

Practice these — they are the backbone of every later section:

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | n | Open file explorer (oil.nvim) at the current file's directory |
| `<leader>E` | n | Open explorer at the working directory |
| `<leader>ff` | n | Find files (fzf-lua) |
| `<leader>fr` | n | Recent files |
| `<leader><space>` | n | Switch buffers |
| `<leader>s/` | n | Live grep across the project |
| `<leader>s*` | n | Grep the word under the cursor |
| `<leader>st` | n | Search TODO / FIXME comments |
| `<leader>:` | n | Command history |
| `<leader>S` | n | Save |
| `<leader>c` | n | Close buffer |
| `<leader>Z` | n | Quit |
| `<C-h/j/k/l>` | n | Move between splits |
| `<leader>-` / `<leader>\|` | n | Split below / right |
| `<leader>=` | n | Equalize splits |
| `<A-j>` / `<A-k>` | n/v | Move line(s) down / up |

Editing essentials:

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | n | Toggle line comment |
| `gc` | n/v | Toggle comment over motion/selection |
| `sa{` | n/v | Add surround (e.g. `sa(` wraps in parens) |
| `sd{` | n | Delete a surrounding pair |
| `sr({` | n | Replace surround `(` with `{` |
| `gnn` / `grn` / `grm` / `grc` | n | Treesitter: init / grow node / grow scope / shrink |

Treesitter text objects (usable with any operator, e.g. `daf` = delete around function):

- `af` / `if` — around / inside function
- `ac` / `ic` — around / inside class
- `ab` / `ib` — around / inside block
- `]f` / `[f` — jump to next / previous function

Discoverability: press `<leader>` alone and pause — `which-key` shows every group
(`<leader>e`, `<leader>f`, `<leader>s`, `<leader>g`, `<leader>l`, `<leader>p`,
`<leader>j`, `<leader>d`, `<leader>t`, `<leader>T`, `<leader>W`). You rarely need
to memorize anything.

Shared LSP keys (work in both Python and Java once a server has attached):

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gr` | n | Find references |
| `gi` | n | Go to implementation |
| `gt` | n | Go to type definition |
| `K` | n | Hover documentation |
| `<C-k>` | i | Signature help |
| `<leader>la` | n/v | Code action |
| `<leader>lr` | n | Rename symbol |
| `<leader>lf` | n/v | Format via LSP |
| `<leader>ls` | n | Workspace symbols |
| `<leader>ld` | n | Document symbols |

Sessions are saved/restored automatically per project. Manual control:
`:SessionSave`, `:SessionRestore`, `:SessionDelete`.

You are ready. Quit with `<leader>Z` and move on.

---

## Part 2 — Python tutorial

Goal: create a small Python project, write a function + a test, get LSP +
formatting on save, run the tests from inside Neovim, and debug it with DAP.

### 2.1 Create the project with `uv`

```bash
cd ~/ide-tutorial
uv init calc
cd calc
uv venv                       # creates .venv (auto-detected by Neovim)
uv add --dev pytest debugpy
```

`uv` is the preferred runner. When it is on `$PATH`, every run/test command inside
Neovim uses `uv run python …` so the project interpreter is picked automatically.
If `uv` is absent the config falls back to the detected venv or `python3`.

### 2.2 Open the project and write code

```bash
nvim src/calc.py
```

Type:

```python
def add(a: int, b: int) -> int:
    return a + b


def divide(a: int, b: int) -> float:
    if b == 0:
        raise ValueError("b must not be zero")
    return a / b
```

`basedpyright` attaches automatically (Python buffer + detected `.venv`). Watch
the statusline/diagnostics. `ruff` handles linting, formatting, and import
organization; it is preferred over basedpyright wherever they overlap.

### 2.3 Add a test

Create the test file:

```vim
:e tests/test_calc.py
```

```python
from calc import add, divide

import pytest


def test_add():
    assert add(2, 3) == 5


def test_divide_by_zero():
    with pytest.raises(ValueError):
        divide(1, 0)
```

### 2.4 Save and let the config do its thing

Write the file with `:w` (or `<leader>S`). For Python buffers only, on every save:

1. `BufWritePre` requests `source.organizeImports` from Ruff and applies it.
2. Then `vim.lsp.buf.format()` formats the buffer with Ruff.

Both steps are synchronous, so the save never races with the formatter.

### 2.5 Run and test from inside Neovim

All Python keymaps are under `<leader>p` and active only in Python buffers.

| Key | Action |
|-----|--------|
| `<leader>pr` | Run current file (`uv run python <file>`) |
| `<leader>pm` | Run current module |
| `<leader>ps` | (Visual) Run selected code |
| `<leader>pt` | pytest — current file |
| `<leader>ptf` | pytest — function/method under the cursor (node ID built from treesitter) |
| `<leader>ptp` | pytest — whole project |
| `<leader>pi` | Organize imports (Ruff) |
| `<leader>pf` | Format with Ruff (n or v) |
| `<leader>pv` | Show the detected Python interpreter |

Try it:

1. Open `tests/test_calc.py`, put the cursor inside `test_add`, press
   `<leader>ptf` — only that test runs in a split terminal.
2. Press `<leader>pt` — the whole file's tests run.
3. Press `<leader>ptp` — the full project test suite runs.
4. Open `src/calc.py` and press `<leader>pr` to run the module.

There is also a generic task layer under `<leader>t` that dispatches to the Python
provider automatically:

| Key | Action |
|-----|--------|
| `<leader>tr` | Run the current file |
| `<leader>ts` | Run tests for the current project |
| `<leader>tc` | Clean build artifacts (removes all `__pycache__` dirs) |

No test-UI plugin is used; output goes to a split terminal buffer.

### 2.6 Debug with DAP

`debugpy` auto-detects `.venv`. The debugger lazy-loads on first use.

1. Open `src/calc.py`, put the cursor on `return a + b`, press `<leader>db` to
   toggle a breakpoint (a sign appears in the gutter).
2. Press `<leader>dc` to start debugging (`<leader>dc` = Continue/Start).
   - `nvim-dap-ui` opens automatically: scopes, breakpoints, watches, call stack,
     REPL, and console.
   - `nvim-dap-virtual-text` shows variable values inline.
3. Step with `<leader>do` (over) / `<leader>di` (into) / `<leader>dO` (out).
4. Toggle the UI with `<leader>du`; open a REPL with `<leader>dr`.
5. Stop with `<leader>dt`; clear all breakpoints with `<leader>dx`.

Conditional breakpoint: `<leader>dB` (prompts for a condition, e.g. `b == 0`).

### 2.7 Which interpreter did Neovim pick?

Press `<leader>pv`. The detection order is:

1. `VIRTUAL_ENV` environment variable
2. `<root>/.venv/bin/python`
3. `<root>/venv/bin/python`

This covers `venv`, `.venv`, and `uv` environments (all default to `.venv`).
`basedpyright` is told the chosen path via `workspace/didChangeConfiguration` when
it attaches. Performance: `basedpyright` uses `diagnosticMode = "openFilesOnly"`,
and `.venv`, `__pycache__`, `.pytest_cache`, `.mypy_cache` are added to
`wildignore` so navigation never scans them.

You have now built, tested, formatted, and debugged Python. Quit and move on.

---

## Part 3 — Java tutorial

Goal: open a Maven project, let jdtls index it, navigate/ refactor, run JUnit
tests, and debug them — all without leaving Neovim.

### 3.1 (One-time) install Java tooling

Already installed in Part 1, but for reference:

```bash
brew install openjdk@8 openjdk@11 openjdk@17 jdtls lombok \
  google-java-format maven gradle
```

For test **debugging** you also need the `java-debug` and `java-test` extension
bundles; add their JARs to the folders searched by `lua/languages/java-debug.lua`
(or adjust the glob patterns there).

### 3.2 Create a Maven project

```bash
cd ~/ide-tutorial
mvn -B archetype:generate \
  -DarchetypeGroupId=org.apache.maven.archetypes \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DgroupId=com.example \
  -DartifactId=calc-java \
  -Dversion=1.0-SNAPSHOT
cd calc-java
nvim
```

### 3.3 Let jdtls index the workspace

Open any `*.java` file, e.g. `<leader>ff` → `App.java`. `jdtls` starts lazily via
`require("jdtls").start_or_attach(config)` and uses a per-project workspace:

```
~/.cache/jdtls/<project-name>
```

The workspace is reused across sessions, so the first open is slower (indexing)
and subsequent opens are fast. CodeLens (references/implementation counts) appears
and refreshes on save and on buffer enter.

JDK selection:

1. If `JAVA_HOME` is set, it is used as-is.
2. Otherwise the config searches common Homebrew/Temurin paths for JDK 17, 11, 8
   (in that order) and picks the newest.
3. Pin a project to a JDK by creating `.java-version` in the root with a major
   version, e.g. `11`.

Lombok (if installed via Homebrew) is auto-added as a Java agent
(`-javaagent:/opt/homebrew/opt/lombok/libexec/lombok.jar`). JVM defaults are
`-Xms1G -Xmx4G -XX:+UseG1GC`; override with `NVIM_JDTLS_XMS`, `NVIM_JDTLS_XMX`,
`NVIM_JDTLS_GC`.

### 3.4 Write some code

Edit `src/main/java/com/example/App.java`:

```java
package com.example;

public class App {
    public static int add(int a, int b) {
        return a + b;
    }

    public static double divide(int a, int b) {
        if (b == 0) {
            throw new IllegalArgumentException("b must not be zero");
        }
        return (double) a / b;
    }

    public static void main(String[] args) {
        System.out.println(add(2, 3));
    }
}
```

Add a test `src/test/java/com/example/AppTest.java` (JUnit 5):

```java
package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AppTest {
    @Test
    void adds() {
        assertEquals(5, App.add(2, 3));
    }

    @Test
    void dividesByZero() {
        assertThrows(IllegalArgumentException.class, () -> App.divide(1, 0));
    }
}
```

Format on save is automatic for `*.java` via `google-java-format` through
`conform.nvim`. Manual format: `<leader>jf`.

### 3.5 Navigate and refactor

Use the shared LSP keys from Part 1.5 (`gd`, `gr`, `gi`, `gt`, `K`, `<leader>la`,
`<leader>lr`). Java-specific extras:

| Key / Command | Action |
|---------------|--------|
| `<leader>ji` / `:JavaOrganizeImports` | Organize imports |
| `:JavaAddMissingImports` | Add missing imports |
| `:JavaRemoveUnusedImports` | Remove unused imports |
| `:JavaExtractMethod` | Extract method |
| `:JavaExtractVariable` | Extract variable |
| `:JavaExtractConstant` | Extract constant |
| `:JavaInlineVariable` | Inline variable |
| `:JavaMoveType` | Move type |
| `<leader>jr` | Refactor code-action menu |
| `:JavaIncomingCalls` / `:JavaOutgoingCalls` | Call hierarchy (in/out) |
| `<leader>jh` / `:JavaTypeHierarchy` | Type hierarchy |
| `:JavaImplementationHierarchy` | Implementation hierarchy |

Try it: put the cursor on `add`, press `gd` to jump to its definition, then `gr`
to see references. Press `<leader>lr` to rename it across the project.

### 3.6 Build with Maven/Gradle

The build system is detected from `pom.xml`, `build.gradle`, `settings.gradle`,
or `settings.gradle.kts` (searching upward from the current file).

| Key | Maven | Gradle |
|-----|-------|--------|
| `<leader>jc` | `mvn compile` | `gradle classes` |
| `<leader>jp` | `mvn package` | `gradle assemble` |
| `<leader>jv` | `mvn verify` | `gradle check` |
| (`:JavaX` test/clean/install) | `mvn test` / `mvn clean` / `mvn install` | `gradle test` / `gradle clean` / `gradle publishToMavenLocal` |

Press `<leader>jc` to compile. Build output dirs (`target/`, `build/`, `.gradle/`,
`.idea/`) are excluded from wild searches via `wildignore`.

### 3.7 Run and debug tests

Supported frameworks: JUnit 4, JUnit 5, TestNG. Nearest-method and class-level
tests use `nvim-jdtls`; package/module runs fall back to the detected build tool.

| Key | Action |
|-----|--------|
| `<leader>jt` | Run nearest test |
| `<leader>jT` | Run current class tests |
| `<leader>jd` | Debug nearest test |
| `<leader>jD` | Debug test class |

Or use the generic Testing menu (works in any buffer with a registered provider):

| Key | Action |
|-----|--------|
| `<leader>Tt` | Run nearest test |
| `<leader>Tc` | Run test class |
| `<leader>Tp` | Run package tests |
| `<leader>Tm` | Run module tests |
| `<leader>Tl` | Re-run last test |
| `<leader>Td` | Debug nearest test |
| `<leader>TD` | Debug test class |

Try it: open `AppTest.java`, cursor on `adds()`, press `<leader>jt`. Then press
`<leader>jd` to debug that same test — DAP UI opens, hits your breakpoint, and you
step with `<leader>do`/`<leader>di`/`<leader>dO` (same DAP keys as Python).

### 3.8 Manage the jdtls workspace

| Key / Command | Action |
|---------------|--------|
| `<leader>Wb` / `:JavaBuildWorkspace` | Build workspace |
| `<leader>Wr` / `:JavaReloadWorkspace` | Reload workspace configuration |
| `<leader>Ww` / `:JavaRestartJdtls` | Restart jdtls |
| `<leader>Wc` / `:JavaClearWorkspaceCache` | Clear workspace cache |
| `<leader>Wl` / `:JavaOpenWorkspaceLogs` | Open workspace logs |
| `<leader>jw`, `<leader>jl` | Aliases for restart and logs |

If imports or rename ever look stale, `<leader>Ww` to restart jdtls, or
`<leader>Wc` to clear the cache.

You have now built, navigated, refactored, tested, and debugged Java.

---

## Part 4 — Git and lazygit

Git tooling lazy-loads only inside Git repositories, so the `<leader>g` mappings
appear automatically when you need them.

### 4.1 Initialize a repo (if your project isn't one yet)

```bash
cd ~/ide-tutorial/calc   # or calc-java
git init
git add -A
git commit -m "Initial commit"
```

### 4.2 Hunk-level work with gitsigns

`gitsigns.nvim` shows hunk signs in the gutter and current-line blame (300 ms
delay). These keys work in any buffer:

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gn` / `<leader>gp` | n | Jump to next / previous hunk |
| `<leader>gh` | n | Preview the current hunk (floating) |
| `<leader>gb` | n | Blame the current line |
| `<leader>gs` | n/v | Stage hunk |
| `<leader>gr` | n/v | Reset hunk |
| `<leader>gu` | n | Undo stage hunk |
| `<leader>gD` | n | Diff this buffer against the index |

A typical loop: edit a file, `<leader>gn` to hop through changed hunks,
`<leader>gh` to review each one, `<leader>gs` to stage the ones you want,
`<leader>gr` to discard a bad change.

### 4.3 Review changes with diffview

| Key / Command | Action |
|-----|--------|
| `<leader>gd` | Open Diffview for all current changes |
| `:DiffviewOpen branch...HEAD` | Compare current branch against another |
| `:DiffviewOpen <commit>` | Inspect a specific commit |
| `:DiffviewFileHistory %` | History of the current file |
| `:DiffviewClose` | Close Diffview |

`<leader>gd` is the quickest way to review everything you've changed before
committing.

### 4.4 lazygit — the main event

Open it with `<leader>gg` (or `:LazyGit`). It opens in a centered floating
terminal (90% of the editor) and closes automatically when you quit lazygit. If
lazygit isn't installed you'll get `brew install lazygit`; if you're not in a
repo you'll get a warning. (`lazygit` is installed by the dotfiles Brewfile.)

Lazygit is a full TUI for Git. Press `?` inside it at any time to see every
contextual key for the current panel. The top bar shows panels you switch between
with `1`–`5` (or `h`/`l` / `[`/`]`):

- **1 Status / Files** — overview of staged & unstaged files
- **2 Files** — working-tree changes
- **3 Branches** — local/remote branches, create/switch/rebase/cherry-pick
- **4 Commits** — commit history, amend, reword, fixup, squash
- **5 Stash** — stashes

Core keys (from the Status/Files panel):

| Key | Action |
|-----|--------|
| `<space>` | Stage / unstage the selected file or hunk |
| `a` | Stage all (toggle) |
| `c` | Write a commit message and commit |
| `C` | Commit using a previous message |
| `w` | Commit without a pre-commit hook |
| `P` | Push to upstream |
| `p` | Pull |
| `e` | Edit the selected file in `$EDITOR` (Neovim) |
| `d` | Discard / reset selected changes |
| `r`, `m`, `i` | Rebase / merge / interactively rebase (Branches/Commits) |
| `z` | Undo (undo the last lazygit action) |
| `?` | Show all keys for the current panel |
| `q` / `<Esc>` | Quit lazygit (returns to Neovim, window auto-closes) |

When you edit a file from inside lazygit (`e`) it opens in the Neovim that
launched it. After committing, close lazygit (`q`) and the `<leader>g` hunk signs
update automatically.

A complete session:

1. Make edits in Neovim (Python or Java).
2. `<leader>gd` to review all changes; fix anything.
3. `<leader>gg` to open lazygit.
4. In the Files panel: `<space>` to stage hunks, or `a` to stage all.
5. `c`, type a message, save & quit the message buffer — committed.
6. `P` to push. `q` to leave lazygit.

That's the entire round-trip without ever opening a separate terminal.

### 4.5 Dedicated Git terminal (optional)

`<leader>tg` opens a dedicated, reusable vertical "Git" terminal via
`toggleterm.nvim` for raw `git` commands. It is reused, never duplicated. (Other
terminals: `<leader>tt` horizontal, `<leader>tf` floating, `<leader>ta` Agent
floating.)

---

## Quick reference cheat sheet

| Want to… | Do this |
|----------|---------|
| See all key groups | press `<leader>` and pause (which-key) |
| Find a file | `<leader>ff` |
| Grep the project | `<leader>s/` |
| Go to definition / references | `gd` / `gr` |
| Rename a symbol | `<leader>lr` |
| Format the current buffer | `<leader>lf` |
| Run the current Python file | `<leader>pr` |
| Run the Python test under the cursor | `<leader>ptf` |
| Debug (Python or Java) | `<leader>db` (breakpoint) → `<leader>dc` (start) |
| Compile a Java project | `<leader>jc` |
| Run the Java test under the cursor | `<leader>jt` |
| Restart jdtls | `<leader>Ww` |
| Organize Go imports | `<leader>lI` (in Go buffers) |
| Open lazygit | `<leader>gg` |
| Review all current changes | `<leader>gd` |
| Select or change languages | `~/Development/dotfiles/scripts/languages.sh` |
| Check the environment | `:DevHealth` |

For the full reference, see the other docs in this folder:

- [`languages.md`](languages.md) — [`installation.md`](installation.md) —
  [`keymaps.md`](keymaps.md) — [`python.md`](python.md) — [`java.md`](java.md) —
  [`debugging.md`](debugging.md) — [`terminal.md`](terminal.md) —
  [`tasks.md`](tasks.md) — [`health.md`](health.md) —
  [`troubleshooting.md`](troubleshooting.md) — [`faq.md`](faq.md)
