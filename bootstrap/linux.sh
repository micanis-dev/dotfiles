#!/usr/bin/env sh
set -eu

profile="${1:-linux-headless}"

case "$profile" in
  linux-gui|linux-headless)
    ;;
  *)
    echo "Usage: $0 [linux-gui|linux-headless]" >&2
    exit 1
    ;;
esac

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

nix build ".#homeConfigurations.${profile}.activationPackage"
./result/activate
