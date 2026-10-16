# micanis dotfiles

macOS・Linux・NixOS の開発環境を Nix flake で宣言的に管理する dotfiles です。

| 構成名 | 対象 | 仕組み |
| --- | --- | --- |
| `darwinConfigurations.darwin` | macOS (Apple Silicon) | nix-darwin + Home Manager + Homebrew Cask |
| `homeConfigurations.linux-gui` | NixOS 以外の Linux デスクトップ | Home Manager (standalone) |
| `homeConfigurations.linux-headless` | NixOS 以外の Linux サーバー | Home Manager (standalone) |
| `nixosConfigurations.nixos` | NixOS | NixOS modules + Home Manager |

設計方針の詳細は [docs/architecture.md](docs/architecture.md)、macOS で管理している設定の一覧は
[docs/darwin-settings.md](docs/darwin-settings.md) を参照してください。

## ディレクトリ構成

```text
.
├── flake.nix              # 入口。全構成とその共通引数を定義
├── bootstrap/             # 新しいマシンへの初回導入スクリプト
│   ├── install.sh         #   curl | sh 用。clone して darwin.sh / linux.sh へ
│   ├── darwin.sh          #   Nix・Homebrew を入れて nix-darwin を適用
│   ├── linux.sh           #   Nix を入れて Home Manager を適用
│   └── lib.sh             #   darwin.sh / linux.sh の共通関数
├── hosts/                 # 構成ごとの入口。どのモジュールを使うかだけを書く
├── modules/
│   ├── home/              # Home Manager（ユーザー環境）
│   │   ├── common/        #   全環境共通: CLI ツール、シェル、Git、エディタ…
│   │   ├── darwin/        #   macOS 専用: Karabiner、既定アプリ、AI エージェント
│   │   └── linux/         #   Linux 専用（gui.nix はデスクトップ向け追加分）
│   ├── darwin/            # nix-darwin（macOS のシステム設定・Homebrew）
│   ├── nixos/             # NixOS のシステム設定
│   └── home-manager.nix   # nix-darwin / NixOS に Home Manager を組み込む共通設定
├── config/                # 各アプリの設定ファイル本体（そのままの形式で保存）
└── docs/
```

## 初回セットアップ

新しいマシンでは次の 1 行で、Nix の導入・リポジトリの clone・構成の適用まで行います。
リポジトリは `~/.local/share/dotfiles` に置かれます（`DOTFILES_DIR` で変更可）。

```sh
curl -fsSL https://raw.githubusercontent.com/micanis-dev/dotfiles/main/bootstrap/install.sh | sh
```

Linux では引数でプロファイルを選べます（省略時は `linux-headless`）。

```sh
curl -fsSL https://raw.githubusercontent.com/micanis-dev/dotfiles/main/bootstrap/install.sh | sh -s -- linux-gui
```

### macOS の初回のみ必要な作業

nix-darwin が `/etc/shells` を管理するため、初回の適用で既存ファイルと衝突した場合は
退避してから再実行します。

```sh
sudo mv /etc/shells /etc/shells.before-nix-darwin
./bootstrap/darwin.sh
```

## 日常の操作

設定を変更したら、リポジトリのルートで次を実行して反映します。

| 対象 | コマンド |
| --- | --- |
| macOS | `sudo darwin-rebuild switch --flake .#darwin` |
| Linux | `home-manager switch --flake .#linux-gui`（または `.#linux-headless`） |
| NixOS | `sudo nixos-rebuild switch --flake .#nixos` |

Nix flake は Git に登録されていないファイルを無視します。新しいファイルを追加したら、
適用前に `git add` してください。

### よくある変更の置き場所

| やりたいこと | 編集するファイル |
| --- | --- |
| 全環境に CLI ツールを追加 | `modules/home/common/packages.nix` |
| macOS に GUI アプリを追加 | `modules/darwin/apps.nix`（Homebrew Cask / Mac App Store） |
| macOS のシステム設定を変更 | `modules/darwin/defaults.nix` |
| シェルのエイリアス・関数を追加 | `config/nushell/scripts/aliases.nu`, `functions.nu` |
| エディタやターミナルの設定 | `config/<アプリ名>/` |
| キー配列（Karabiner）を変更 | `config/karabiner/karabiner.json` |

### 依存の更新

```sh
nix flake update            # すべての input を更新
nix flake update nixpkgs    # 特定の input だけ更新
```

## 検証

```sh
nix develop                 # nixfmt / nil / statix / deadnix 入りのシェル
nixfmt $(git ls-files '*.nix')
nix build .#darwinConfigurations.darwin.system --dry-run
nix build .#homeConfigurations.linux-gui.activationPackage --dry-run
nix build .#homeConfigurations.linux-headless.activationPackage --dry-run
```

`nixosConfigurations.nixos` はハードウェア設定（ブートローダーやファイルシステム）を
含んでいないため、このままでは評価に失敗します。実機に導入するときは、その機械で
生成した `hardware-configuration.nix` を `hosts/nixos/` に追加して import してください。
