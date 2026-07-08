#!/usr/bin/env sh
set -eu

if ! xcode-select -p >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Apple Command Line Tools are required before bootstrapping this Mac.

Run:
  xcode-select --install

After the installation finishes, rerun the bootstrap command.
EOF
  exit 1
fi

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Nix." >&2
    exit 1
  fi

  curl -L https://nixos.org/nix/install | sh -s -- --daemon
  export PATH="/nix/var/nix/profiles/default/bin:$PATH"
}

install_nix

if ! command -v nix >/dev/null 2>&1; then
  echo "nix is not available after installation. Open a new shell and rerun this script." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

nix build .#darwinConfigurations.darwin.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#darwin
