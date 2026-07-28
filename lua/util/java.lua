local M = {}

local function find_jdks()
  local jdks = {}
  local home = vim.fn.expand("~")
  local brew_prefix = vim.fn.exists("$HOMEBREW_PREFIX") == 1 and vim.env.HOMEBREW_PREFIX
    or (vim.fn.isdirectory("/opt/homebrew") == 1 and "/opt/homebrew" or "/usr/local")

  local bases = {
    [8] = {
      home .. "/.local/share/mise/installs/java/8",
      home .. "/.local/share/mise/installs/java/temurin-8",
      brew_prefix .. "/opt/openjdk@8/libexec/openjdk.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home",
      "/usr/local/opt/openjdk@8/libexec/openjdk.jdk/Contents/Home",
    },
    [11] = {
      home .. "/.local/share/mise/installs/java/11",
      home .. "/.local/share/mise/installs/java/temurin-11",
      brew_prefix .. "/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home",
      "/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home",
    },
    [17] = {
      home .. "/.local/share/mise/installs/java/17",
      home .. "/.local/share/mise/installs/java/temurin-17",
      brew_prefix .. "/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home",
      "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home",
      "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home",
    },
  }

  for version, paths in pairs(bases) do
    for _, p in ipairs(paths) do
      if vim.fn.isdirectory(p) == 1 then
        jdks[version] = p
        break
      end
    end
  end

  return jdks
end

function M.resolve_jdk()
  if vim.env.JAVA_HOME and vim.fn.isdirectory(vim.env.JAVA_HOME) == 1 then
    return vim.env.JAVA_HOME
  end
  local jdks = find_jdks()
  for _, v in ipairs({ 17, 11, 8 }) do
    if jdks[v] then
      return jdks[v]
    end
  end
  return nil
end

function M.pick_jdk_for_project(root)
  if not root then
    return M.resolve_jdk()
  end
  local ok, f = pcall(io.open, root .. "/.java-version", "r")
  if ok and f then
    local wanted = tonumber((f:read("*l") or ""):match("(%d+)"))
    f:close()
    if wanted then
      local jdks = find_jdks()
      if jdks[wanted] then
        return jdks[wanted]
      end
    end
  end
  return M.resolve_jdk()
end

function M.find_lombok_jar()
  local home = vim.fn.expand("~")
  local brew_prefix = vim.fn.exists("$HOMEBREW_PREFIX") == 1 and vim.env.HOMEBREW_PREFIX
    or (vim.fn.isdirectory("/opt/homebrew") == 1 and "/opt/homebrew" or "/usr/local")

  local candidates = {
    home .. "/.local/share/ide-tools/lombok.jar",
    brew_prefix .. "/opt/lombok/libexec/lombok.jar",
    brew_prefix .. "/opt/lombok/libexec/lombok-1.18.34.jar",
    "/usr/local/opt/lombok/libexec/lombok.jar",
  }

  for _, c in ipairs(candidates) do
    if vim.fn.filereadable(c) == 1 then
      return c
    end
  end

  local matches = vim.fn.glob(brew_prefix .. "/Cellar/lombok/*/libexec/lombok*.jar", false, true)
  if type(matches) == "table" and #matches > 0 then
    return matches[1]
  end

  return nil
end

function M.workspace_dir(root)
  local name = root and vim.fn.fnamemodify(root, ":t") or "unknown"
  return vim.fn.expand("~/.cache/jdtls") .. "/" .. name
end

function M.jdtls_cmd(root)
  local cmd = { "jdtls" }
  local jdk = M.pick_jdk_for_project(root)
  if jdk then
    vim.list_extend(cmd, { "--java-executable", jdk .. "/bin/java" })
  end
  local lombok = M.find_lombok_jar()
  if lombok then
    vim.list_extend(cmd, { "--jvm-arg", "-javaagent:" .. lombok })
  end
  local xms = vim.env.NVIM_JDTLS_XMS or "-Xms1G"
  local xmx = vim.env.NVIM_JDTLS_XMX or "-Xmx4G"
  local gc = vim.env.NVIM_JDTLS_GC or "-XX:+UseG1GC"
  for _, arg in ipairs({ xms, xmx, gc }) do
    vim.list_extend(cmd, { "--jvm-arg", arg })
  end
  vim.list_extend(cmd, { "-data", M.workspace_dir(root) })
  return cmd
end

return M
