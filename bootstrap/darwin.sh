#!/usr/bin/env sh
set -eu

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Nix." >&2
    exit 1
  fi

  curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install
  export PATH="/nix/var/nix/profiles/default/bin:$PATH"
}

install_homebrew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    export PATH="/opt/homebrew/bin:$PATH"
    return
  fi

  if [ -x /usr/local/bin/brew ]; then
    export PATH="/usr/local/bin:$PATH"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Homebrew." >&2
    exit 1
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif [ -x /usr/local/bin/brew ]; then
    export PATH="/usr/local/bin:$PATH"
  fi
}

run_nix() {
  nix --extra-experimental-features "nix-command flakes" "$@"
}

install_nix

if ! command -v nix >/dev/null 2>&1; then
  echo "nix is not available after installation. Open a new shell and rerun this script." >&2
  exit 1
fi

install_homebrew

if ! command -v brew >/dev/null 2>&1; then
  echo "homebrew is not available after installation. Open a new shell and rerun this script." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

run_nix build .#darwinConfigurations.darwin.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#darwin
