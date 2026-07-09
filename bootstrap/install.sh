#!/usr/bin/env sh
set -eu

repo_url="${DOTFILES_REPO:-https://github.com/micanis-dev/dotfiles.git}"
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
    Darwin|Linux)
      curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install
      ;;
    *)
      echo "Unsupported system: $(uname -s)" >&2
      exit 1
      ;;
  esac

  export PATH="/nix/var/nix/profiles/default/bin:$PATH"
}

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
if [ -f "$script_dir/install.sh" ] && [ -f "$script_dir/../flake.nix" ]; then
  target_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
else
  install_nix

  if ! command -v nix >/dev/null 2>&1; then
    echo "nix is not available after installation. Open a new shell and rerun this script." >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_dir")"

  if [ -d "$target_dir/.git" ]; then
    DOTFILES_DIR="$target_dir" nix-shell -p git --run 'git -C "$DOTFILES_DIR" pull --ff-only'
  elif [ -e "$target_dir" ]; then
    echo "$target_dir exists but is not a git repository." >&2
    exit 1
  else
    DOTFILES_REPO="$repo_url" DOTFILES_DIR="$target_dir" nix-shell -p git --run 'git clone "$DOTFILES_REPO" "$DOTFILES_DIR"'
  fi
fi

case "$(uname -s)" in
  Darwin)
    exec "$target_dir/bootstrap/darwin.sh"
    ;;
  Linux)
    profile="${1:-linux-headless}"
    exec "$target_dir/bootstrap/linux.sh" "$profile"
    ;;
  *)
    echo "Unsupported system: $(uname -s)" >&2
    exit 1
    ;;
esac
