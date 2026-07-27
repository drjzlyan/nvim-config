# Java Development

This document describes the Java development environment added in Phase 5 and
extended in Phase 9.

## Architecture

Java support is split across several files to keep concerns separate:

- `lua/features/java.lua` — plugin configuration for `conform.nvim`, which runs
  `google-java-format`.
- `lua/languages/java.lua` — `jdtls` setup, autocommands, and provider
  registrations.
- `lua/languages/java-commands.lua` — buffer-local commands and keymaps for
  imports, refactoring, call hierarchy, and workspace management.
- `lua/languages/java-project.lua` — Maven and Gradle project command helpers.
- `lua/languages/java-testing.lua` — Java test runner adapter for the generic
  testing module.
- `lua/util/java.lua` — shared JDK, Lombok, and jdtls command helpers.

Generic LSP keymaps, diagnostics, and handlers remain in `lua/features/lsp.lua`.

## External tools

Install these with Homebrew (the configuration does not install them for you):

```bash
brew install openjdk@8 openjdk@11 openjdk@17 jdtls lombok google-java-format maven gradle
```

For test debugging you also need `java-debug` and `java-test` bundles. Add their
extension JARs to the folders searched by `lua/languages/java-debug.lua` or
adjust the glob patterns there.

## Workspace layout

`jdtls` requires a dedicated workspace directory per project so that indexes,
imports, and build state persist across sessions. The configuration uses:

```
~/.cache/jdtls/<project-name>
```

where `<project-name>` is the last component of the project root. The workspace
is reused automatically; no manual setup is required.

## Supported JDKs

The configuration supports JDK 8, 11, and 17.

1. If `JAVA_HOME` is set in the environment, it is used as-is.
2. Otherwise the configuration searches common Homebrew and Eclipse Temurin
   paths for JDK 17, 11, and 8 (in that order) and picks the newest available.

You can pin a project to a specific JDK by creating a `.java-version` file in
the project root containing a major version number, for example:

```
11
```

## Lombok

If Lombok is installed via Homebrew, the configuration automatically adds it as
a Java agent:

```
-javaagent:/opt/homebrew/opt/lombok/libexec/lombok.jar
```

No manual configuration is required.

## JVM options

Reasonable defaults are used for the `jdtls` JVM:

- `-Xms1G`
- `-Xmx4G`
- `-XX:+UseG1GC`

You can override them with environment variables:

```bash
export NVIM_JDTLS_XMS="-Xms2G"
export NVIM_JDTLS_XMX="-Xmx8G"
export NVIM_JDTLS_GC="-XX:+UseZGC"
```

## Formatting

Java formatting uses `google-java-format` through `conform.nvim`. Formatting
runs automatically on `:w` for `*.java` files. You can also trigger it manually
with `<leader>jf`.

## Maven and Gradle

Projects are detected by looking for any of:

- `pom.xml`
- `build.gradle`
- `settings.gradle`
- `settings.gradle.kts`

The project root is the first directory (searching upward from the current file)
that contains one of these files, falling back to the file's directory.

`<leader>jc` compiles the current project, `<leader>jp` packages it, and
`<leader>jv` runs the verification goal. The exact command is chosen based on
the build system:

| Command | Maven | Gradle |
|---------|-------|--------|
| Compile | `mvn compile` | `gradle classes` |
| Package | `mvn package` | `gradle assemble` |
| Verify  | `mvn verify`  | `gradle check` |
| Test    | `mvn test`    | `gradle test` |
| Clean   | `mvn clean`   | `gradle clean` |
| Install | `mvn install` | `gradle publishToMavenLocal` |

## LSP features

`jdtls` is started only when a Java file is opened. It provides:

- Go to definition
- Find references
- Rename
- Hover
- Go to implementation
- Go to type definition
- Workspace symbols
- Document symbols
- Call hierarchy
- Code actions

## CodeLens

jdtls CodeLens is enabled for references and implementations. Lenses refresh
automatically when you save a `*.java` file or enter a Java buffer.

## Imports

Buffer-local commands and keymaps are available for import management:

| Key / Command | Action |
|---------------|--------|
| `<leader>ji` / `:JavaOrganizeImports` | Organize imports |
| `:JavaAddMissingImports` | Add missing imports |
| `:JavaRemoveUnusedImports` | Remove unused imports |

## Refactoring

jdtls refactorings are exposed as direct commands and keymaps:

| Command | Action |
|---------|--------|
| `:JavaExtractMethod` | Extract method |
| `:JavaExtractVariable` | Extract variable |
| `:JavaExtractConstant` | Extract constant |
| `:JavaInlineVariable` | Inline variable |
| `:JavaMoveType` | Move type |
| `<leader>lr` / `:JavaRename` | Rename symbol |

`<leader>jr` opens the full refactor code-action menu.

## Call and type hierarchy

| Key / Command | Action |
|---------------|--------|
| `:JavaIncomingCalls` | Incoming call hierarchy |
| `:JavaOutgoingCalls` | Outgoing call hierarchy |
| `<leader>jh` / `:JavaTypeHierarchy` | Type hierarchy |
| `:JavaImplementationHierarchy` | Implementation hierarchy |

## Testing

The generic testing layer in `lua/features/testing.lua` delegates Java test
execution to `lua/languages/java-testing.lua`, which uses `nvim-jdtls` for
nearest-method and class-level tests. Package and module test runs fall back to
the detected build tool.

Supported frameworks: JUnit 4, JUnit 5, and TestNG.

| Key | Action |
|-----|--------|
| `<leader>jt` | Run nearest test |
| `<leader>jT` | Run current class tests |
| `<leader>Tt` | Run nearest test (Testing menu) |
| `<leader>Tc` | Run current class tests (Testing menu) |
| `<leader>Tp` | Run package tests |
| `<leader>Tm` | Run module tests |
| `<leader>Tl` | Re-run last test |
| `<leader>jd` | Debug nearest test |
| `<leader>jD` | Debug current class tests |
| `<leader>Td` | Debug nearest test (Testing menu) |
| `<leader>TD` | Debug current class tests (Testing menu) |

## Workspace management

| Key / Command | Action |
|---------------|--------|
| `<leader>Wb` / `:JavaBuildWorkspace` | Build workspace |
| `<leader>Wr` / `:JavaReloadWorkspace` | Reload workspace configuration |
| `<leader>Ww` / `:JavaRestartJdtls` | Restart jdtls |
| `<leader>Wc` / `:JavaClearWorkspaceCache` | Clear workspace cache |
| `<leader>Wl` / `:JavaOpenWorkspaceLogs` | Open workspace logs |
| `<leader>jw`, `<leader>jl` | Alias keymaps for restart and logs |

## Keymaps

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

## Performance

- `jdtls` is only attached in Java buffers.
- Build output directories (`target/`, `build/`, `.gradle/`, `.idea/`) are
  excluded from wild searches via `wildignore`.
- Workspaces are reused per project, avoiding costly re-imports.
- Project metadata is cached in `lua/util/project.lua` and reused by Java
  project, testing, and task providers.
