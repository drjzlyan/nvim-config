#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/share/ide-tools}"
BIN_DIR="$TOOLS_DIR/bin"
LANGUAGES_FILE="${LANGUAGES_FILE:-$HOME/.local/share/nvim/languages.local}"

mkdir -p "$TOOLS_DIR" "$BIN_DIR"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/tools.lock"

log() {
  printf '[install-tools] %s\n' "$*"
}

# ---------------------------------------------------------------------------
# Language selection helpers
# ---------------------------------------------------------------------------

selected_languages=()
if [[ -f "$LANGUAGES_FILE" ]]; then
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -n "$line" ]] && selected_languages+=("$line")
  done < "$LANGUAGES_FILE"
fi

has_language() {
  local lang="$1"
  for s in "${selected_languages[@]}"; do
    [[ "$s" == "$lang" ]] && return 0
  done
  return 1
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
  local version="$2"
  log "Installing $name==$version"
  uv tool install --force "$name==$version"
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
  local version="$JDTLS_VERSION"
  local target="$TOOLS_DIR/jdtls-$version"
  if [[ -d "$target" ]]; then
    log "jdtls $version already installed"
  else
    local tmp
    tmp=$(mktemp -d)
    local url
    url=$(eval echo "$JDTLS_URL")
    log "Downloading jdtls $version..."
    curl -fsSL "$url" -o "$tmp/jdtls.tar.gz"
    verify_checksum "$tmp/jdtls.tar.gz" "$JDTLS_SHA256" || return 1
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
  local version="$LOMBOK_VERSION"
  local target="$TOOLS_DIR/lombok-$version.jar"
  if [[ -f "$target" ]]; then
    log "lombok $version already installed"
  else
    log "Downloading lombok $version..."
    curl -fsSL "$LOMBOK_URL" -o "$target"
    verify_checksum "$target" "$LOMBOK_SHA256" || return 1
  fi
  rm -f "$TOOLS_DIR/lombok.jar"
  ln -s "$target" "$TOOLS_DIR/lombok.jar"
  log "Installed lombok -> $TOOLS_DIR/lombok.jar"
}

install_vsix() {
  local name="$1"
  local version_var="$2"
  local url_var="$3"
  local sha_var="$4"
  local version="${!version_var}"
  local url
  url=$(eval echo "${!url_var}")
  local expected_sha="${!sha_var}"
  local target="$TOOLS_DIR/$name-$version"
  if [[ -d "$target" ]]; then
    log "$name $version already installed"
  else
    local tmp
    tmp=$(mktemp -d)
    local archive="$tmp/$name.vsix"
    log "Downloading $name $version..."
    curl -fsSL "$url" -o "$archive"
    verify_checksum "$archive" "$expected_sha" || return 1
    mkdir -p "$target"
    unzip -q "$archive" -d "$target"
    rm -rf "$tmp"
  fi
  rm -f "$TOOLS_DIR/$name"
  ln -s "$target" "$TOOLS_DIR/$name"
  log "Installed $name -> $TOOLS_DIR/$name"
}

# ---------------------------------------------------------------------------
# Main: install tools only for selected languages
# ---------------------------------------------------------------------------

main() {
  if [[ ${#selected_languages[@]} -eq 0 ]]; then
    log "No languages selected. Run the dotfiles language selector first:"
    log "  ~/Development/dotfiles/scripts/languages.sh"
    log "Installing common tools only."
  fi

  # Python
  if has_language "python"; then
    if ! command -v uv >/dev/null 2>&1; then
      log "uv is required for Python tools"
    else
      install_uv_tool basedpyright "$BASEDPYRIGHT_VERSION"
      install_uv_tool ruff "$RUFF_VERSION"
    fi
  fi

  # Java
  if has_language "java"; then
    install_jdtls
    install_lombok
    install_vsix java-debug JAVA_DEBUG_VERSION JAVA_DEBUG_URL JAVA_DEBUG_SHA256
    install_vsix java-test JAVA_TEST_VERSION JAVA_TEST_URL JAVA_TEST_SHA256
  fi

  # TypeScript / JavaScript
  if has_language "typescript"; then
    install_npm_tool typescript-language-server "$TSSERVER_VERSION"
    install_npm_tool typescript "$TYPESCRIPT_VERSION"
    install_npm_tool prettier "$PRETTIER_VERSION"
  fi

  # Go
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
