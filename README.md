# micanis dotfiles

Nix flake based dotfiles for Darwin, Linux, and NixOS targets.

## Outputs

- `darwinConfigurations.darwin`
- `homeConfigurations.linux-gui`
- `homeConfigurations.linux-headless`
- `nixosConfigurations.nixos`

## Apply

Fresh machine:

```sh
curl -fsSL https://raw.githubusercontent.com/micanis-dev/dotfiles/main/bootstrap/install.sh | sh
```

Darwin:

```sh
./bootstrap/darwin.sh
```

This applies:

- macOS user defaults via nix-darwin: locale, keyboard repeat, dark mode, scroll direction, menu bar, Finder, Dock, screenshot target, and Touch ID sudo.
- Home Manager user files: shell, git, direnv, starship, helix, nushell, zellij, ssh, and Ghostty config.
- Homebrew GUI apps declared in `modules/darwin/apps.nix`.

See `docs/darwin-settings.md` for the managed macOS settings checklist and
source-machine inspection commands.

Linux GUI:

```sh
./bootstrap/linux.sh linux-gui
```

Linux headless:

```sh
./bootstrap/linux.sh linux-headless
```

NixOS:

```sh
sudo nixos-rebuild switch --flake .#nixos
```

## Check

```sh
nix flake check
nix build .#darwinConfigurations.darwin.system --dry-run
nix build .#homeConfigurations.linux-gui.activationPackage --dry-run
nix build .#homeConfigurations.linux-headless.activationPackage --dry-run
```

## Inspect macOS defaults

Use these commands before changing `modules/darwin/system.nix` to compare the
current machine with the declarative nix-darwin values:

```sh
defaults read NSGlobalDomain
defaults read com.apple.finder
defaults read com.apple.desktopservices
defaults read com.apple.dock
defaults read com.apple.screencapture
defaults read com.apple.menuextra.clock
defaults read com.apple.controlcenter
```
