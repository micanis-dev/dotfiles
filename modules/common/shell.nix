{
  home.sessionVariables = {
    COLORTERM = "truecolor";
    EDITOR = "hx";
    VISUAL = "hx";
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.bash = {
    enable = true;
    profileExtra = ''
      [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
    '';
    initExtra = ''
      command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
    '';
  };

  programs.zsh = {
    enable = true;
    envExtra = ''
      export XDG_CONFIG_HOME="$HOME/.config"
      export COLORTERM="truecolor"
    '';
    initContent = ''
      [[ -o interactive ]] || return

      command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
      command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
      command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
    '';
  };

  programs.zoxide.enable = true;
}
