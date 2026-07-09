{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zellij
    nushell
    helix
    ripgrep
    fd
    bat
    eza
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
    marksman
    taplo
  ];
}
