# dotfiles 設計

## 目的

本リポジトリは、複数OS・複数ホストの開発環境を **Nix** を中心に管理することを目的とする。

対象環境は以下の通り。

* macOS
* Linux (GUI)
* Linux (Headless)
* NixOS
* Alpine Linux

基本思想は以下とする。

* Home Manager を中心にユーザー環境を管理する
* macOS は nix-darwin を利用する
* NixOS は NixOS Modules を利用する
* 開発環境は Flakes + devShell + nix-direnv を利用する
* Alpine は例外として最低限の bootstrap を許容する
* chezmoi は使用しない

---

# 設計方針

## 基本原則

責務を明確に分離する。

| 責務          | 担当                |
| ----------- | ----------------- |
| OS設定(macOS) | nix-darwin        |
| OS設定(NixOS) | NixOS Modules     |
| ユーザー環境      | Home Manager      |
| 開発環境        | Flakes + devShell |
| 初回導入        | bootstrap script  |

---

## サポート対象

### macOS

* GUI
* nix-darwin
* Home Manager
* Homebrew(Cask)

### Linux (GUI)

* Home Manager

### Linux (Headless)

* Home Manager

### NixOS

* NixOS Modules
* Home Manager

### Alpine

原則は Home Manager を利用する。

ただし以下の場合は bootstrap のみ利用する。

* コンテナ
* 最小環境
* Nix導入が適さない環境

---

# ディレクトリ構成

```text
dotfiles/
├── flake.nix
├── flake.lock
├── README.md
│
├── bootstrap/
│   ├── install.sh
│   ├── darwin.sh
│   ├── linux.sh
│   └── alpine.sh
│
├── hosts/
│   ├── mac-mini/
│   ├── linux-gui/
│   ├── linux-headless/
│   ├── nixos/
│   └── alpine/
│
├── modules/
│   ├── common/
│   ├── darwin/
│   ├── linux/
│   └── nixos/
│
├── config/
│   ├── helix/
│   ├── nushell/
│   ├── starship.toml
│   └── ssh/
│
└── templates/
    ├── python/
    ├── cpp/
    └── rust/
```

---

# hosts

ホスト固有設定のみ記述する。

例

```
hosts/mac-mini
```

には

* ホスト名
* GUI有無
* Homebrew Cask
* Mac固有設定

のみを書く。

共通設定は書かない。

---

# modules

## common

全OS共通。

### packages

CLIツール

* git
* ripgrep
* fd
* bat
* eza
* jq
* yq
* fzf
* yazi
* lazygit
* gh
* dust
* procs
* hyperfine
* tokei

### shell

* zsh
* nushell
* PATH
* aliases

### starship

Prompt設定

### helix

Editor設定

### nushell

Nushell設定

### ssh

SSH設定

### direnv

* direnv
* nix-direnv

### zellij

Terminal Multiplexer

---

## darwin

macOS専用。

* Finder
* Dock
* Keyboard
* TouchID sudo
* Homebrew
* GUI Applications

---

## linux

Linux共通。

GUIあり・なしの差分のみ分離する。

```
linux/
├── gui.nix
└── headless.nix
```

---

## nixos

NixOS専用。

* services
* users
* networking
* fonts
* hardware
* boot

---

# config

アプリケーション設定をそのまま保存する。

可能な限り Home Manager の option に変換せず、

```
config/
```

以下へ置き、

```
xdg.configFile
```

で配置する。

例

```
config/
├── helix/
├── nushell/
└── starship.toml
```

これにより既存設定をほぼそのまま利用できる。

---

# bootstrap

bootstrap は **Nix導入まで** を担当する。

責務は以下のみ。

1. OS判定
2. Nix導入
3. Git取得
4. dotfiles clone
5. switch実行

Nix導入後の設定は一切書かない。

---

# GUIアプリ

GUIアプリは Homebrew Cask を利用する。

例

* Ghostty
* Google Chrome
* Docker Desktop
* Cursor
* Slack
* Discord

CLIは Home Manager で管理する。

---

# 開発環境

開発環境は Home Manager では管理しない。

プロジェクト単位で

* flake.nix
* devShell
* nix-direnv

を利用する。

例

```
project/
├── flake.nix
└── .envrc
```

---

# Alpineの扱い

Alpineは例外。

以下のどちらかを選択する。

* Home Manager
* bootstrapのみ

無理にNixへ統一しない。

---

# chezmoiからの移行

削除対象

* .chezmoi.toml
* .chezmoiscripts
* .chezmoiignore
* dot_zshrc
* dot_profile
* dot_zshenv
* dot_bashrc

移行対象

```
dot_config/
```

↓

```
config/
```

へ移動する。

テンプレート機能は利用しない。

---

# 完成形

新品PCで以下のみ実行する。

```bash
curl -fsSL https://<domain>/install.sh | sh
```

実行後は

* Nix
* Home Manager
* nix-darwin
* CLI
* GUIアプリ
* dotfiles

がすべて再現されることを目標とする。

---

# 今後の拡張

将来的には以下も管理対象とする。

* 秘密情報（sops-nix / agenix）
* ホスト自動判定
* CIによるflakeチェック
* GitHub Actionsによるテスト
* 開発テンプレートの自動生成
* 共通ライブラリ化
