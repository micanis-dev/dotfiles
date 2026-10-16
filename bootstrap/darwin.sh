#!/usr/bin/env sh
# Apply darwinConfigurations.darwin (nix-darwin + Home Manager + Homebrew).
set -eu

# shellcheck source=bootstrap/lib.sh
. "$(dirname "$0")/lib.sh"

# Add Homebrew to PATH, installing it first when it is missing.
ensure_homebrew() {
  for prefix in /opt/homebrew /usr/local; do
    if [ -x "$prefix/bin/brew" ]; then
      export PATH="$prefix/bin:$PATH"
      return
    fi
  done

  if ! command -v brew >/dev/null 2>&1; then
    require_curl Homebrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    for prefix in /opt/homebrew /usr/local; do
      if [ -x "$prefix/bin/brew" ]; then
        export PATH="$prefix/bin:$PATH"
        break
      fi
    done
  fi

  command -v brew >/dev/null 2>&1 ||
    die "homebrew is not available after installation. Open a new shell and rerun this script."
}

ensure_nix
ensure_homebrew
cd_repo_root

# darwin-rebuild is not installed yet on a fresh Mac, so build the system
# first and use the darwin-rebuild it contains.
run_nix build .#darwinConfigurations.darwin.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#darwin
