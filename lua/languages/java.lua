local M = {}

-- ============================================================================
-- Project detection
-- ============================================================================

local java_root_markers = {
  "pom.xml",
  "build.gradle",
  "settings.gradle",
  "settings.gradle.kts",
  ".git",
}

local function project_root(bufnr)
  bufnr = bufnr or 0
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    path = vim.fn.getcwd()
  end
  return vim.fs.root(path, java_root_markers) or vim.fs.dirname(path)
end

local function project_name(root)
  if not root or root == "" then
    return "unknown"
  end
  return vim.fn.fnamemodify(root, ":t")
end

-- ============================================================================
-- JDK detection
-- ============================================================================

local function find_jdks()
  local jdks = {}
  local function try(path)
    if path and vim.fn.isdirectory(path) == 1 then
      return path
    end
    return nil
  end

  -- Direct versioned Homebrew paths for Intel and Apple Silicon
  local brew_prefix = vim.fn.exists("$HOMEBREW_PREFIX") == 1 and vim.env.HOMEBREW_PREFIX
    or (vim.fn.isdirectory("/opt/homebrew") == 1 and "/opt/homebrew" or "/usr/local")

  local candidates = {
    [8] = {
      brew_prefix .. "/opt/openjdk@8/libexec/openjdk.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/openjdk-8.jdk/Contents/Home",
      "/usr/local/opt/openjdk@8/libexec/openjdk.jdk/Contents/Home",
    },
    [11] = {
      brew_prefix .. "/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home",
      "/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home",
    },
    [17] = {
      brew_prefix .. "/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home",
      "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home",
    },
  }

  for version, paths in pairs(candidates) do
    for _, p in ipairs(paths) do
      local home = try(p)
      if home then
        jdks[version] = home
        break
      end
    end
  end

  return jdks
end

local function resolve_jdk()
  -- Respect the active JAVA_HOME first.
  if vim.env.JAVA_HOME and vim.fn.isdirectory(vim.env.JAVA_HOME) == 1 then
    return vim.env.JAVA_HOME
  end

  local jdks = find_jdks()
  -- Prefer the newest stable JDK, but allow older ones if needed.
  for _, v in ipairs({ 17, 11, 8 }) do
    if jdks[v] then
      return jdks[v]
    end
  end

  return nil
end

local function pick_jdk_for_project(root)
  -- A project can pin a JDK by placing a `.java-version` file containing
  -- a major version number such as "11" or "17".
  if not root then
    return resolve_jdk()
  end
  local version_file = root .. "/.java-version"
  local f = io.open(version_file, "r")
  if f then
    local content = f:read("*l") or ""
    f:close()
    local wanted = tonumber(content:match("(%d+)"))
    if wanted then
      local jdks = find_jdks()
      if jdks[wanted] then
        return jdks[wanted]
      end
    end
  end
  return resolve_jdk()
end

-- ============================================================================
-- Lombok detection
-- ============================================================================

local function find_lombok_jar()
  local brew_prefix = vim.fn.exists("$HOMEBREW_PREFIX") == 1 and vim.env.HOMEBREW_PREFIX
    or (vim.fn.isdirectory("/opt/homebrew") == 1 and "/opt/homebrew" or "/usr/local")

  local candidates = {
    brew_prefix .. "/opt/lombok/libexec/lombok.jar",
    brew_prefix .. "/opt/lombok/libexec/lombok-1.18.34.jar",
    brew_prefix .. "/Cellar/lombok/*/libexec/lombok*.jar",
    "/usr/local/opt/lombok/libexec/lombok.jar",
  }

  for _, c in ipairs(candidates) do
    if c:find("%*") then
      local matches = vim.fn.glob(c, false, true)
      if type(matches) == "table" and #matches > 0 then
        return matches[1]
      end
    elseif vim.fn.filereadable(c) == 1 then
      return c
    end
  end

  return nil
end

-- ============================================================================
-- jdtls workspace and command
-- ============================================================================

local function workspace_dir(root)
  local name = project_name(root)
  local base = vim.fn.expand("~/.cache/jdtls")
  return base .. "/" .. name
end

local function jdtls_cmd(root)
  local cmd = { "jdtls" }

  local jdk = pick_jdk_for_project(root)
  if jdk then
    vim.list_extend(cmd, { "--java-executable", jdk .. "/bin/java" })
  end

  local lombok = find_lombok_jar()
  if lombok then
    vim.list_extend(cmd, { "--jvm-arg", "-javaagent:" .. lombok })
  end

  -- Default JVM options; can be overridden via environment variables.
  local xms = vim.env.NVIM_JDTLS_XMS or "-Xms1G"
  local xmx = vim.env.NVIM_JDTLS_XMX or "-Xmx4G"
  local gc = vim.env.NVIM_JDTLS_GC or "-XX:+UseG1GC"

  for _, arg in ipairs({ xms, xmx, gc }) do
    vim.list_extend(cmd, { "--jvm-arg", arg })
  end

  vim.list_extend(cmd, { "-data", workspace_dir(root) })

  return cmd
end

-- ============================================================================
-- Formatting with conform.nvim
-- ============================================================================

local function format_java()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({
      bufnr = 0,
      async = false,
      lsp_format = "fallback",
    })
  else
    vim.notify("conform.nvim is not available", vim.log.levels.WARN)
  end
end

-- ============================================================================
-- Code actions
-- ============================================================================

local function organize_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
  if #clients == 0 then
    vim.notify("jdtls is not attached", vim.log.levels.WARN)
    return
  end

  local params = {
    command = "java.action.organizeImports",
    arguments = { vim.uri_from_bufnr(bufnr) },
  }
  clients[1]:exec_cmd(params, { bufnr = bufnr })
end

-- ============================================================================
-- Placeholder project commands
-- ============================================================================

local function send_to_terminal(cmd, cwd, name)
  name = name or "shell"
  cwd = cwd or vim.fn.getcwd()
  local terminal = require("features.terminal")
  if type(cmd) == "table" then
    cmd = table.concat(cmd, " ")
  end
  terminal.send(name, cmd, { dir = cwd })
end

local function compile_project()
  local root = project_root(0)
  local cmd
  if vim.fn.filereadable(root .. "/pom.xml") == 1 then
    cmd = { "mvn", "compile" }
  elseif vim.fn.filereadable(root .. "/build.gradle") == 1
    or vim.fn.filereadable(root .. "/settings.gradle") == 1
    or vim.fn.filereadable(root .. "/settings.gradle.kts") == 1
  then
    cmd = { "gradle", "build" }
  else
    vim.notify("No Maven or Gradle project found", vim.log.levels.WARN)
    return
  end
  send_to_terminal(cmd, root, "build")
end

local function run_maven()
  local root = project_root(0)
  if vim.fn.filereadable(root .. "/pom.xml") ~= 1 then
    vim.notify("No pom.xml found", vim.log.levels.WARN)
    return
  end
  send_to_terminal({ "mvn" }, root, "build")
end

local function run_gradle()
  local root = project_root(0)
  local has_gradle = vim.fn.filereadable(root .. "/build.gradle") == 1
    or vim.fn.filereadable(root .. "/settings.gradle") == 1
    or vim.fn.filereadable(root .. "/settings.gradle.kts") == 1
  if not has_gradle then
    vim.notify("No Gradle project found", vim.log.levels.WARN)
    return
  end
  send_to_terminal({ "gradle" }, root, "build")
end

-- ============================================================================
-- Commands and keymaps
-- ============================================================================

local function register_commands(bufnr)
  local cmds = {
    { "JavaFormat", format_java, { desc = "Format Java with google-java-format" } },
    { "JavaOrganizeImports", organize_imports, { desc = "Organize Java imports" } },
    { "JavaCompile", compile_project, { desc = "Compile Java project" } },
    { "JavaMaven", run_maven, { desc = "Run Maven" } },
    { "JavaGradle", run_gradle, { desc = "Run Gradle" } },
  }

  for _, c in ipairs(cmds) do
    vim.api.nvim_buf_create_user_command(bufnr, c[1], c[2], c[3])
  end
end

local function register_keymaps(bufnr)
  local map = function(keys, fn, modes, desc)
    modes = modes or "n"
    vim.keymap.set(modes, keys, fn, { buffer = bufnr, silent = true, desc = desc })
  end

  map("<leader>jf", format_java, { "n", "v" }, "Format Java")
  map("<leader>ji", organize_imports, { "n" }, "Organize imports")
  map("<leader>jc", compile_project, { "n" }, "Compile project")
  map("<leader>jm", run_maven, { "n" }, "Run Maven")
  map("<leader>jg", run_gradle, { "n" }, "Run Gradle")
end

-- ============================================================================
-- LSP setup (jdtls)
-- ============================================================================

local function setup_lsp()
  local lspconfig = require("lspconfig")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  -- jdtls is configured once per project. The same workspace directory is
  -- reused across sessions so imports, indexes, and build state persist.
  -- The command is computed per-root via on_new_config so each project gets
  -- its own workspace and JDK selection.
  lspconfig.jdtls.setup({
    capabilities = capabilities,
    root_dir = function(path)
      return vim.fs.root(path, java_root_markers)
    end,
    single_file_support = true,
    on_new_config = function(new_config, new_root_dir)
      new_config.cmd = jdtls_cmd(new_root_dir)
    end,
    init_options = {
      bundles = require("languages.java-debug").bundles(),
    },
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
        },
        configuration = {
          updateBuildConfiguration = "automatic",
        },
      },
    },
  })
end

-- ============================================================================
-- Autocommands: register commands and keymaps for Java buffers only
-- ============================================================================

local java_augroup = vim.api.nvim_create_augroup("JavaDev", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = java_augroup,
  pattern = "java",
  callback = function(args)
    setup_lsp()
    register_commands(args.buf)
    register_keymaps(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = java_augroup,
  pattern = "*.java",
  callback = function()
    format_java()
  end,
})

-- ============================================================================
-- Performance: keep searches out of build output
-- ============================================================================

vim.opt.wildignore:append("*/target/*,*/build/*,*/.gradle/*,*/.idea/*")

-- ============================================================================
-- Generic task provider
-- ============================================================================

local function is_maven(root)
  return vim.fn.filereadable(root .. "/pom.xml") == 1
end

local function is_gradle(root)
  return vim.fn.filereadable(root .. "/build.gradle") == 1
    or vim.fn.filereadable(root .. "/settings.gradle") == 1
    or vim.fn.filereadable(root .. "/settings.gradle.kts") == 1
end

local java_provider = {
  detect = function(bufnr)
    local root = project_root(bufnr)
    return is_maven(root) or is_gradle(root)
  end,

  build = function(bufnr)
    local root = project_root(bufnr)
    if is_maven(root) then
      return { cmd = { "mvn", "package" }, cwd = root }
    elseif is_gradle(root) then
      return { cmd = { "gradle", "build" }, cwd = root }
    end
    return nil
  end,

  test = function(bufnr)
    local root = project_root(bufnr)
    if is_maven(root) then
      return { cmd = { "mvn", "test" }, cwd = root }
    elseif is_gradle(root) then
      return { cmd = { "gradle", "test" }, cwd = root }
    end
    return nil
  end,

  run_file = function()
    return nil
  end,

  run_project = function(bufnr)
    local root = project_root(bufnr)
    if is_maven(root) then
      return { cmd = { "mvn" }, cwd = root }
    elseif is_gradle(root) then
      return { cmd = { "gradle" }, cwd = root }
    end
    return nil
  end,

  clean = function(bufnr)
    local root = project_root(bufnr)
    if is_maven(root) then
      return { cmd = { "mvn", "clean" }, cwd = root }
    elseif is_gradle(root) then
      return { cmd = { "gradle", "clean" }, cwd = root }
    end
    return nil
  end,
}

local ok, tasks = pcall(require, "features.tasks")
if ok then
  tasks.register("java", java_provider)
end

-- This module is loaded by lazy.nvim's `import = "languages"` mechanism.
return {}
