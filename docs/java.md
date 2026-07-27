# Java Development

This document describes the Java development environment added in Phase 5.

## Architecture

Java support is split across two files to keep concerns separate:

- `lua/features/java.lua` — plugin configuration for `conform.nvim`, which runs
  `google-java-format`.
- `lua/languages/java.lua` — language-specific logic: JDK detection, Lombok
  discovery, `jdtls` command construction, project detection, commands,
  keymaps, and format-on-save.

Generic LSP keymaps, diagnostics, and handlers remain in `lua/features/lsp.lua`.

## External tools

Install these with Homebrew (the configuration does not install them for you):

```bash
brew install openjdk@8 openjdk@11 openjdk@17 jdtls lombok google-java-format maven gradle
```

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

`<leader>jc` compiles the current project using Maven or Gradle depending on
the project type. `<leader>jm` and `<leader>jg` open a terminal ready for
Maven or Gradle commands, respectively.

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
- Organize imports

## Keymaps

| Key | Mode | Action |
|-----|------|--------|
| `<leader>jf` | n / v | Format with google-java-format |
| `<leader>ji` | n | Organize imports |
| `<leader>jc` | n | Compile project |
| `<leader>jm` | n | Run Maven |
| `<leader>jg` | n | Run Gradle |

## Performance

- `jdtls` is only attached in Java buffers.
- Build output directories (`target/`, `build/`, `.gradle/`, `.idea/`) are
  excluded from wild searches via `wildignore`.
- Workspaces are reused per project, avoiding costly re-imports.
