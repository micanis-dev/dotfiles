{
  programs = {
    git = {
      enable = true;
      settings = {
        user.name = "micanis";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
