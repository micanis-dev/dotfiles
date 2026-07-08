# micanis dotfiles

Nix flake based dotfiles for Darwin, Linux, NixOS, and Alpine targets.

## Outputs

- `darwinConfigurations.darwin`
- `homeConfigurations.linux-gui`
- `homeConfigurations.linux-headless`
- `homeConfigurations.alpine`
- `nixosConfigurations.nixos`

## Apply

Fresh machine:

```sh
curl -fsSL https://raw.githubusercontent.com/micanis/dotfiles/main/bootstrap/install.sh | sh
```

Darwin:

```sh
./bootstrap/darwin.sh
```

Linux GUI:

```sh
./bootstrap/linux.sh linux-gui
```

Linux headless:

```sh
./bootstrap/linux.sh linux-headless
```

Alpine:

```sh
./bootstrap/alpine.sh
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
nix build .#homeConfigurations.alpine.activationPackage --dry-run
```
