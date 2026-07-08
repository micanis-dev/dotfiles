#!/usr/bin/env sh
set -eu

repo_url="${DOTFILES_REPO:-https://github.com/micanis/dotfiles.git}"
target_dir="${DOTFILES_DIR:-$HOME/.local/share/dotfiles}"

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Nix." >&2
    exit 1
  fi

  case "$(uname -s)" in
    Darwin)
      curl -L https://nixos.org/nix/install | sh -s -- --daemon
      export PATH="/nix/var/nix/profiles/default/bin:$PATH"
      ;;
    Linux)
      if [ -f /etc/alpine-release ]; then
        curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
        export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
      else
        curl -L https://nixos.org/nix/install | sh -s -- --daemon
        export PATH="/nix/var/nix/profiles/default/bin:$PATH"
      fi
      ;;
    *)
      echo "Unsupported system: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

clone_dotfiles() {
  mkdir -p "$(dirname "$target_dir")"

  if command -v git >/dev/null 2>&1; then
    git clone "$repo_url" "$target_dir"
    return
  fi

  install_nix

  if ! command -v nix >/dev/null 2>&1; then
    echo "nix is not available after installation. Open a new shell and rerun this script." >&2
    exit 1
  fi

  nix shell nixpkgs#git --command git clone "$repo_url" "$target_dir"
}

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ -f "$script_dir/../flake.nix" ]; then
  target_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
elif [ ! -d "$target_dir/.git" ]; then
  clone_dotfiles
fi

case "$(uname -s)" in
  Darwin)
    exec "$target_dir/bootstrap/darwin.sh"
    ;;
  Linux)
    if [ -f /etc/alpine-release ]; then
      exec "$target_dir/bootstrap/alpine.sh"
    fi

    profile="${1:-linux-headless}"
    exec "$target_dir/bootstrap/linux.sh" "$profile"
    ;;
  *)
    echo "Unsupported system: $(uname -s)" >&2
    exit 1
    ;;
esac
