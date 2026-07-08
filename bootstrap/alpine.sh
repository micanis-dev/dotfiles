#!/usr/bin/env sh
set -eu

if [ "${DOTFILES_ALPINE_BOOTSTRAP_ONLY:-0}" = "1" ]; then
  echo "Alpine bootstrap-only mode selected; skipping Home Manager activation."
  exit 0
fi

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Nix." >&2
    exit 1
  fi

  curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
  export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
}

install_nix

if ! command -v nix >/dev/null 2>&1; then
  echo "nix is not available after installation. Open a new shell and rerun this script." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

nix build .#homeConfigurations.alpine.activationPackage
./result/activate
