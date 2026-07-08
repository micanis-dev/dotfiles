#!/usr/bin/env sh
set -eu

archive_url="${DOTFILES_ARCHIVE_URL:-https://github.com/micanis-dev/dotfiles/archive/refs/heads/main.tar.gz}"
target_dir="${DOTFILES_DIR:-$HOME/.local/share/dotfiles}"

fetch_dotfiles() {
  mkdir -p "$(dirname "$target_dir")"

  if [ -e "$target_dir" ]; then
    echo "$target_dir already exists but does not look like this dotfiles repository." >&2
    exit 1
  fi

  if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    echo "curl and tar are required to fetch dotfiles." >&2
    exit 1
  fi

  tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles.XXXXXX")
  archive_file="$tmp_dir/dotfiles.tar.gz"

  curl -fsSL "$archive_url" -o "$archive_file"
  top_dir=$(tar -tzf "$archive_file" | sed -n '1s,/.*,,p')
  if [ -z "$top_dir" ]; then
    echo "Unable to determine dotfiles archive root." >&2
    exit 1
  fi

  tar -xzf "$archive_file" -C "$tmp_dir"
  mv "$tmp_dir/$top_dir" "$target_dir"
  rm -rf "$tmp_dir"
}

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ -f "$script_dir/../flake.nix" ]; then
  target_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
elif [ ! -f "$target_dir/flake.nix" ]; then
  fetch_dotfiles
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
