{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zellij
    nushell
    helix
    starship
    ripgrep
    fd
    bat
    eza
    zoxide
    fzf
    yazi
    delta
    gh
    lazygit
    dust
    procs
    hyperfine
    tokei
    jq
    yq-go
    direnv
    marksman
    taplo
  ];
}
