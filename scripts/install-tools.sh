#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/share/ide-tools}"
BIN_DIR="$TOOLS_DIR/bin"

mkdir -p "$TOOLS_DIR" "$BIN_DIR"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/tools.lock"

log() {
  printf '[install-tools] %s\n' "$*"
}

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

main() {
  if ! command -v uv >/dev/null 2>&1; then
    log "uv is required to install Python tools"
    exit 1
  fi

  install_uv_tool basedpyright "$BASEDPYRIGHT_VERSION"
  install_uv_tool ruff "$RUFF_VERSION"

  install_jdtls
  install_lombok
  install_vsix java-debug JAVA_DEBUG_VERSION JAVA_DEBUG_URL JAVA_DEBUG_SHA256
  install_vsix java-test JAVA_TEST_VERSION JAVA_TEST_URL JAVA_TEST_SHA256

  log "All external tools installed to $TOOLS_DIR"
}

main "$@"
