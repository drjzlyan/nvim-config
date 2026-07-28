#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/share/ide-tools}"
BIN_DIR="$TOOLS_DIR/bin"
LANGUAGES_FILE="${LANGUAGES_FILE:-$HOME/.local/share/nvim/languages.local}"

mkdir -p "$TOOLS_DIR" "$BIN_DIR"

log() {
  printf '[install-tools] %s\n' "$*"
}

# ---------------------------------------------------------------------------
# Language selection helpers (reads key=value format)
# ---------------------------------------------------------------------------

selected_languages=()
declare -A selected_versions=()

if [[ -f "$LANGUAGES_FILE" ]]; then
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue
    local_lang="${line%%=*}"
    local_ver="${line#*=}"
    selected_languages+=("$local_lang")
    selected_versions["$local_lang"]="$local_ver"
  done < "$LANGUAGES_FILE"
fi

has_language() {
  local lang="$1"
  for s in "${selected_languages[@]:-}"; do
    [[ "$s" == "$lang" ]] && return 0
  done
  return 1
}

get_version() {
  local lang="$1"
  echo "${selected_versions[$lang]:-latest}"
}

# ---------------------------------------------------------------------------
# Checksum / install helpers
# ---------------------------------------------------------------------------

verify_checksum() {
  local file="$1"
  local expected="$2"
  if [[ -z "$expected" ]]; then
    return 0
  fi
  local actual
  actual=$(shasum -a 256 "$file" | awk '{print $1}')
  if [[ "$actual" != "$expected" ]]; then
    log "Checksum mismatch for $file"
    return 1
  fi
}

install_uv_tool() {
  local name="$1"
  local version="${2:-latest}"
  if [[ "$version" == "latest" ]]; then
    log "Installing $name (latest)"
    uv tool install --force "$name"
  else
    log "Installing $name==$version"
    uv tool install --force "$name==$version"
  fi
}

install_npm_tool() {
  local name="$1"
  local version="${2:-latest}"
  if ! command -v npm >/dev/null 2>&1; then
    log "npm not found; skipping $name"
    return 1
  fi
  if [[ "$version" == "latest" ]]; then
    log "Installing $name (latest)"
    npm install -g "$name"
  else
    log "Installing $name@$version"
    npm install -g "$name@$version"
  fi
}

install_go_tool() {
  local url="$1"
  if ! command -v go >/dev/null 2>&1; then
    log "go not found; skipping $url"
    return 1
  fi
  log "Installing $url"
  go install "$url"
}

install_brew() {
  local pkg="$1"
  if command -v brew >/dev/null 2>&1; then
    if ! brew list "$pkg" >/dev/null 2>&1; then
      log "Installing $pkg via brew"
      brew install "$pkg"
    else
      log "$pkg already installed via brew"
    fi
  else
    log "brew not found; skipping $pkg"
  fi
}

# ---------------------------------------------------------------------------
# Language-specific installers
# ---------------------------------------------------------------------------

install_jdtls() {
  local version="$1"
  local target="$TOOLS_DIR/jdtls-$version"
  if [[ -d "$target" ]]; then
    log "jdtls $version already installed"
  else
    local tmp
    tmp=$(mktemp -d)
    # Construct the download URL dynamically from the version
    local url="https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/${version}/jdt-language-server-${version}.tar.gz"
    log "Downloading jdtls $version..."
    curl -fsSL "$url" -o "$tmp/jdtls.tar.gz"
    verify_checksum "$tmp/jdtls.tar.gz" "" || return 1
    mkdir -p "$target"
    tar -xzf "$tmp/jdtls.tar.gz" -C "$target" --strip-components=1
    rm -rf "$tmp"
  fi
  rm -f "$TOOLS_DIR/jdtls"
  ln -s "$target" "$TOOLS_DIR/jdtls"
  cat > "$BIN_DIR/jdtls" <<EOF
#!/usr/bin/env bash
exec "$TOOLS_DIR/jdtls/bin/jdtls" "\$@"
EOF
  chmod +x "$BIN_DIR/jdtls"
  log "Installed jdtls wrapper -> $BIN_DIR/jdtls"
}

install_lombok() {
  local version="$1"
  local target="$TOOLS_DIR/lombok-$version.jar"
  if [[ -f "$target" ]]; then
    log "lombok $version already installed"
  else
    log "Downloading lombok $version..."
    curl -fsSL "https://projectlombok.org/downloads/lombok-${version}.jar" -o "$target"
    verify_checksum "$target" "" || return 1
  fi
  rm -f "$TOOLS_DIR/lombok.jar"
  ln -s "$target" "$TOOLS_DIR/lombok.jar"
  log "Installed lombok -> $TOOLS_DIR/lombok.jar"
}

install_vsix() {
  local name="$1"
  local version="$2"
  local url_pattern="$3"
  local url="${url_pattern//\$\{VERSION\}/$version}"
  local target="$TOOLS_DIR/$name-$version"
  if [[ -d "$target" ]]; then
    log "$name $version already installed"
  else
    local tmp
    tmp=$(mktemp -d)
    local archive="$tmp/$name.vsix"
    log "Downloading $name $version..."
    curl -fsSL "$url" -o "$archive"
    verify_checksum "$archive" "" || return 1
    mkdir -p "$target"
    unzip -q "$archive" -d "$target"
    rm -rf "$tmp"
  fi
  rm -f "$TOOLS_DIR/$name"
  ln -s "$target" "$TOOLS_DIR/$name"
  log "Installed $name -> $TOOLS_DIR/$name"
}

# ---------------------------------------------------------------------------
# Main: install tools only for selected languages, using selected versions
# ---------------------------------------------------------------------------

main() {
  if [[ ${#selected_languages[@]} -eq 0 ]]; then
    log "No languages selected. Run the dotfiles language selector first:"
    log "  ~/Development/dotfiles/scripts/languages.sh"
    log "Installing common tools only."
  fi

  # Python — tools are always "latest" (basedpyright/ruff update independently)
  if has_language "python"; then
    if ! command -v uv >/dev/null 2>&1; then
      log "uv is required for Python tools"
    else
      install_uv_tool "basedpyright" "latest"
      install_uv_tool "ruff" "latest"
    fi
  fi

  # Java — the Java runtime version is managed by mise, while jdtls is
  # a tool that we install separately at a known stable version.
  if has_language "java"; then
    install_jdtls "1.40.0"
    install_lombok "1.18.34"
    install_vsix "java-debug" "0.58.0" \
      "https://github.com/microsoft/vscode-java-debug/releases/download/v\${VERSION}/vscjava.vscode-java-debug-\${VERSION}.vsix"
    install_vsix "java-test" "0.43.0" \
      "https://github.com/microsoft/vscode-java-test/releases/download/v\${VERSION}/vscjava.vscode-java-test-\${VERSION}.vsix"
  fi

  # TypeScript / JavaScript
  if has_language "typescript"; then
    install_npm_tool "typescript-language-server" "latest"
    install_npm_tool "typescript" "latest"
    install_npm_tool "prettier" "latest"
  fi

  # Go — tools always use @latest (the Go runtime version is from mise)
  if has_language "go"; then
    install_go_tool "golang.org/x/tools/gopls@latest"
    install_go_tool "golang.org/x/tools/cmd/goimports@latest"
    install_go_tool "github.com/go-delve/delve@latest"
  fi

  # C / C++
  if has_language "cpp"; then
    install_brew "clangd"
  fi

  # Rust
  if has_language "rust"; then
    if command -v rustup >/dev/null 2>&1; then
      log "Adding rust-analyzer via rustup"
      rustup component add rust-analyzer
    else
      install_brew "rust-analyzer"
    fi
  fi

  log "Tool installation complete for selected languages: ${selected_languages[*]:-none}"
}

main "$@"
