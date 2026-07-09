# Darwin settings

This file documents the macOS settings currently captured in nix-darwin.
The source of truth is `modules/darwin/system.nix`; this page is a readable
checklist for migration to another Mac.

## Managed settings

| Area | Setting |
| --- | --- |
| User | Primary user is `micanis`; home is `/Users/micanis`; login shell is Nushell |
| Security | Touch ID for `sudo` |
| Locale | Languages `en-JP`, `ja-JP`; locale `en_JP` |
| Keyboard | Caps Lock to Escape; fast key repeat; press-and-hold disabled; Fn keys enabled |
| Appearance | Dark mode |
| Input | Natural scrolling disabled; force click enabled; mouse speed `0.5`; trackpad speed `0.6875` |
| Menu bar | Battery percentage shown; clock shows AM/PM, weekday, and date when space allows |
| Finder | Show hidden files and all extensions; show path/status bars; show POSIX path in title; list view; search current folder; new windows open Home |
| Finder desktop | Show external disks, mounted servers, and removable media; hide internal hard disks |
| Desktop services | Do not write `.DS_Store` files on network or USB volumes |
| Dock | Autohide; no recents; size `58`; Mission Control/App Expose gestures enabled; Desktop/Launchpad gestures disabled |
| Dock items | Vivaldi, Craft, iPhone Mirroring, Notion, Ghostty, and Downloads stack |
| Screenshots | Save screenshots to clipboard |
| Apps | Homebrew casks in `modules/darwin/apps.nix` |
| User files | Home Manager modules under `modules/common` and app config under `config/` |

## Compare a Mac before migrating

Run these commands on the source Mac and compare the stable values with
`modules/darwin/system.nix`.

```sh
defaults read NSGlobalDomain
defaults read com.apple.finder
defaults read com.apple.desktopservices
defaults read com.apple.dock
defaults read com.apple.screencapture
defaults read com.apple.menuextra.clock
defaults read com.apple.controlcenter
```

Do not copy volatile values such as recent files, window bounds, analytics
timestamps, mounted volume positions, or per-device history into Nix.

## Apply on another Mac

```sh
curl -fsSL https://raw.githubusercontent.com/micanis-dev/dotfiles/main/bootstrap/install.sh | sh
```

If nix-darwin cannot take ownership of `/etc/shells` on the first activation,
move the original aside and rerun the Darwin bootstrap:

```sh
sudo mv /etc/shells /etc/shells.before-nix-darwin
./bootstrap/darwin.sh
```
