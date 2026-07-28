# Tutorial: Using the IDE

A hands-on, keystroke-by-keystroke walkthrough for the `dotfiles` + `nvim-config`
development environment. Unlike the reference docs, this guide is sequenced: follow
it top to bottom and you will have selected languages with versions, edited,
built, tested, debugged, and committed code in Python, Java, TypeScript, Go,
C/C++, and Rust, and managed a repository with lazygit.

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

### 1.3 Select programming languages and versions

`install.sh` launches an interactive language selector after the editor config
is linked. Choose languages **and their runtime versions** — versions are
queried dynamically from `mise ls-remote`, so you always see what's available:

```
  ╔═══════════════════════════════════════════════════════════╗
  ║          Language Selection for Neovim IDE                ║
  ╠═══════════════════════════════════════════════════════════╣
  ║  Common languages are always available:                   ║
  ║    JSON, YAML, Bash, Lua, TOML, Markdown                  ║
  ╠═══════════════════════════════════════════════════════════╣
  ║  Toggle languages by number. 'v' to change version.       ║
  ║  Press Enter when done.                                    ║
  ╚═══════════════════════════════════════════════════════════╝

  [✓] 1. python        Python (3.12.7)
  [✓] 2. java          Java (17)
  [ ] 3. typescript    TypeScript/JS
  [ ] 4. go            Go
  [ ] 5. cpp           C/C++ (system)
  [ ] 6. rust          Rust

  Commands: number=toggle, v<number>=version, a=all, n=none, Enter=done
```

When you select a language, the selector fetches available versions from
`mise ls-remote` and shows the most recent stable releases:

```
  Available Python versions (querying mise):
  [*] 1. 3.12.7
      2. 3.12.6
      3. 3.11.10
      4. 3.11.9
      ...
  Enter a number, type a version string, or Enter for default (3.12).
```

To change a version later, use `v<number>` in the menu:

```
 > v1          # change Python version
```

Common languages (JSON, YAML, Bash, Lua, TOML, Markdown) are **always
available** — you don't select them.

To add or remove languages or change versions later (without re-running the
full installer):

```bash
~/Development/dotfiles/scripts/languages.sh          # interactive menu
~/Development/dotfiles/scripts/languages.sh --list   # show current selection
~/Development/dotfiles/scripts/languages.sh --all     # select all + install tools
```

The selection is saved to `~/.local/share/nvim/languages.local` and is
non-destructive — your existing settings are never modified. After changing
the selection, restart Neovim and your shell for the new language modules and
runtime versions to take effect. The `mise.toml` file is generated automatically
from your selection.

The `languages.local` file uses a simple `key=value` format:

```
# Languages and versions configured for this machine.
python=3.12.7
java=17
typescript=20.18.0
go=1.23.3
cpp=system
rust=1.81.0
```

You can edit this file manually and re-run `mise install`, or use the
interactive selector. Both approaches are non-destructive.

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
| `<leader>E` | n | Open file explorer (oil.nvim) at the current file's directory |
| `<leader>O` | n | Open explorer at the working directory |
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
`<leader>j`, `<leader>d`, `<leader>m`, `<leader>T`, `<leader>W`). You rarely need
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

### 1.6 The `dev` tmux session and agent management

The `dev` command launches a pre-configured tmux session with panes for the
editor, an AI coding agent, and a build/test shell, plus a lazygit window.

```bash
dev                     # session named after current dir
dev myproject           # session named "myproject"
dev -a claude           # use a specific agent
dev -k                  # kill existing session and recreate
```

**Agent auto-detection**: if you don't pass `-a`, `dev` scans your `$PATH` for
known coding agents (crush, claude, codex, gemini, aider, copilot). If multiple
are found, an interactive menu appears:

```
  Multiple coding agents detected:

  1. crush
  2. claude
  3. gemini
  0. none (just a shell)

  Enter a number, type a command name, or Enter for #1.
  Ctrl-C cancels (opens a shell).
```

If only one agent is found, it is used automatically. If none are found, a
shell opens in the agent pane. Pressing Ctrl-C at the menu opens a shell (no
agent) — this is the default/reset state.

**In-session agent management** (tmux keybindings, available while you work):

| Key | Action |
|-----|--------|
| `Ctrl-a A` | Interactive agent switcher (type the agent name) |
| `Ctrl-a N` | Cycle to the next detected agent |
| `Ctrl-a D` | Reset pane layout to default (preserves nvim) |

`Ctrl-a D` is the escape hatch: if you accidentally closed a pane, resized
panes badly, or just want to start fresh, it kills all panes except nvim and
rebuilds the default layout. The current agent is relaunched automatically.

**Pane navigation** (vi-style, works in all tmux sessions):

| Key | Action |
|-----|--------|
| `Ctrl-a h/j/k/l` | Move left/down/up/right (vi-style) |
| `Ctrl-a H/J/K/L` | Resize pane (repeatable) |
| `Ctrl-a \|` | Split right |
| `Ctrl-a -` | Split below |
| `Ctrl-a g` | Open lazygit in a new window |
| `Ctrl-a s` | Switch session |
| `Ctrl-a r` | Reload tmux config |

**Checking agent status** from the command line:

```bash
ide-agent status   # show current agent and available agents
```

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

There is also a generic task layer under `<leader>m` that dispatches to the Python
provider automatically:

| Key | Action |
|-----|--------|
| `<leader>ms` | Run tests for the current project |
| `<leader>mc` | Clean build artifacts (removes all `__pycache__` dirs) |
| `<leader>mp` | Run the current project as a module |

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

## Part 3b — TypeScript / JavaScript tutorial

Goal: create a Node.js project, get LSP + formatting, run and build with the
task provider — all inside the IDE.

### 3b.1 Create the project

```bash
cd ~/ide-tutorial
mkdir calc-ts && cd calc-ts
npm init -y
npm install --save-dev typescript @types/node
npx tsc --init
```

### 3b.2 Write code

```bash
nvim src/calc.ts
```

```typescript
export function add(a: number, b: number): number {
  return a + b;
}

export function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error("b must not be zero");
  }
  return a / b;
}
```

`typescript-language-server` attaches automatically when a `.ts` file opens
(root detection: `tsconfig.json` or `package.json`).

### 3b.3 Add a test

```vim
:e src/calc.test.ts
```

```typescript
import { add, divide } from "./calc";

test("add", () => {
  expect(add(2, 3)).toBe(5);
});

test("divide by zero", () => {
  expect(() => divide(1, 0)).toThrow("b must not be zero");
});
```

### 3b.4 Save and format

Write with `:w`. Format on save runs `prettier` for `.ts`, `.tsx`, `.js`, `.jsx`
files. Manual format: `<leader>lf`.

### 3b.5 Run and build

Use the generic task provider (`<leader>t` group) or run directly:

| Action | Command / Key |
|--------|-------------|
| Run current file | `:node %` or the terminal (`<leader>t`) |
| Build project | `<leader>mb` → `npm run build` |
| Run tests | `<leader>ms` → `npm test` |
| Start project | `<leader>mp` → `npm start` |
| Clean | `<leader>mc` → removes `node_modules/`, `dist/`, `build/` |

### 3b.6 Navigate and refactor

Use the shared LSP keys: `gd` (definition), `gr` (references), `gi`
(implementation), `K` (hover), `<leader>la` (code action), `<leader>lr`
(rename). These work identically to Python and Java.

### 3b.7 tmux workflow

Start a `dev` session for a TypeScript project:

```bash
dev calc-ts
```

This opens a 3-pane layout (nvim | agent / build-test) plus a lazygit window.
Run `npm run build` in the bottom-right pane, jump there with `Ctrl-a j`,
jump back to nvim with `Ctrl-a h` (vi-style tmux navigation).

You have now built and tested TypeScript.

---

## Part 3c — Go tutorial

Goal: create a Go module, get `gopls` + format-on-save, run and test with the
task provider, and use the tmux dev session.

### 3c.1 Create the module

```bash
cd ~/ide-tutorial
mkdir calc-go && cd calc-go
go mod init example.com/calc
```

### 3c.2 Write code

```bash
nvim calc.go
```

```go
package calc

func Add(a, b int) int {
	return a + b
}

func Divide(a, b int) float64 {
	if b == 0 {
		panic("b must not be zero")
	}
	return float64(a) / float64(b)
}
```

`gopls` attaches on `FileType go` (root detection: `go.mod` or `go.work`).
Save with `:w` — `goimports` organizes imports, then `gofmt` formats the buffer.

### 3c.3 Add a test

```vim
:e calc_test.go
```

```go
package calc

import "testing"

func TestAdd(t *testing.T) {
	if got := Add(2, 3); got != 5 {
		t.Errorf("Add(2, 3) = %v, want 5", got)
	}
}

func TestDivideByZero(t *testing.T) {
	defer func() { _ = recover() }()
	Divide(1, 0)
}
```

### 3c.4 Run and test

| Action | Key |
|--------|-----|
| Build project | `<leader>mb` → `go build ./...` |
| Run tests | `<leader>ms` → `go test ./...` |
| Run project | `<leader>mp` → `go run .` |
| Clean cache | `<leader>mc` → `go clean -cache` |
| Organize imports manually | `<leader>lI` (in Go buffers) |

### 3c.5 Navigate

`gopls` provides `gd`, `gr`, `gi`, `gt`, `K`, `<leader>la`, `<leader>lr` —
the same shared LSP keys. Staticcheck and nilness analyses are enabled
automatically.

### 3c.6 tmux workflow

```bash
dev calc-go
```

Run `go test ./...` in the build/test pane (`Ctrl-a j`), review failures, fix
in nvim (`Ctrl-a h`), re-run. Use `Ctrl-a g` to open lazygit for committing.

You have now built and tested Go.

---

## Part 3d — C / C++ tutorial

Goal: create a CMake project, get `clangd` with clang-tidy, build with CMake,
and format with clang-format.

### 3d.1 Create the project

```bash
cd ~/ide-tutorial
mkdir calc-cpp && cd calc-cpp
mkdir build
```

Create `CMakeLists.txt`:

```bash
nvim CMakeLists.txt
```

```cmake
cmake_minimum_required(VERSION 3.20)
project(calc CXX)
set(CMAKE_CXX_STANDARD 17)

enable_testing()

add_executable(calc src/calc.cpp src/calc_test.cpp)
target_include_directories(calc PRIVATE src)
add_test(NAME calc_test COMMAND calc)
```

### 3d.2 Write code

```bash
nvim src/calc.cpp
```

```cpp
#pragma once

int add(int a, int b);
double divide(int a, int b);
```

```vim
:e src/calc.cpp
```

```cpp
#include "calc.hpp"

int add(int a, int b) {
    return a + b;
}

double divide(int a, int b) {
    if (b == 0) {
        throw std::invalid_argument("b must not be zero");
    }
    return static_cast<double>(a) / b;
}
```

`clangd` attaches on `FileType c`/`cpp` (root detection:
`compile_commands.json` or `CMakeLists.txt`). It uses background indexing,
clang-tidy, and header insertion (iwyu style).

### 3d.3 Generate compile_commands.json

```bash
cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
```

Restart Neovim or reopen the file — `clangd` picks up
`compile_commands.json` and provides accurate diagnostics.

### 3d.4 Build and test

```bash
cd build && cmake --build . && ctest --output-on-failure
```

Or from inside Neovim via the task provider:

| Action | Key |
|--------|-----|
| Build project | `<leader>mb` → `cmake --build build` |
| Run tests | `<leader>ms` → `ctest --output-on-failure` |
| Clean | `<leader>mc` → `rm -rf build` |

### 3d.5 Format

Save with `:w` — `clang-format` formats automatically. Manual format:
`<leader>lf`. The fallback style is LLVM.

### 3d.6 Navigate

`clangd` provides `gd`, `gr`, `gi`, `gt`, `K`, `<leader>la`, `<leader>lr`.
Completion shows function argument placeholders.

You have now built and tested C/C++.

---

## Part 3e — Rust tutorial

Goal: create a Cargo project, get `rust-analyzer` with clippy + inlay hints,
build, test, and run with the task provider.

### 3e.1 Create the project

```bash
cd ~/ide-tutorial
cargo new calc-rs
cd calc-rs
```

### 3e.2 Write code

```bash
nvim src/main.rs
```

```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

pub fn divide(a: i32, b: i32) -> f64 {
    if b == 0 {
        panic!("b must not be zero");
    }
    a as f64 / b as f64
}

fn main() {
    println!("{}", add(2, 3));
}
```

`rust-analyzer` attaches on `FileType rust` (root detection: `Cargo.toml`).
It enables all cargo features, clippy on save, proc macro support, and inlay
hints (type hints, parameter hints, chaining hints).

### 3e.3 Add a test

```vim
:e src/lib.rs
```

Actually, put tests in the same file:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    #[should_panic(expected = "b must not be zero")]
    fn test_divide_by_zero() {
        divide(1, 0);
    }
}
```

### 3e.4 Save and format

Save with `:w` — `rustfmt` formats via `rust-analyzer`. Inlay hints show
parameter types and names inline. Clippy warnings appear as diagnostics.

### 3e.5 Build, test, and run

| Action | Key |
|--------|-----|
| Build project | `<leader>mb` → `cargo build` |
| Run tests | `<leader>ms` → `cargo test` |
| Run project | `<leader>mp` → `cargo run` |
| Clean | `<leader>mc` → `cargo clean` |

### 3e.6 Navigate

`rust-analyzer` provides `gd`, `gr`, `gi`, `gt`, `K`, `<leader>la`,
`<leader>lr` — the same shared LSP keys. Macro expansions are decoded so
you can navigate into generated code.

### 3e.7 tmux workflow

```bash
dev calc-rs
```

Run `cargo test` in the build/test pane, iterate in nvim, commit via
`Ctrl-a g` (lazygit window).

You have now built and tested Rust.

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

### 4.5 Floating terminal (optional)

`<leader>t` opens a floating terminal via `toggleterm.nvim` for raw `git`
commands or any other shell work. Toggle it again to hide it — it persists
between toggles.

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
