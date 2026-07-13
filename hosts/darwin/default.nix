{
  username,
  homeStateVersion,
  homeDirectory,
  ...
}:
{
  imports = [
    ../../modules/darwin
  ];

  system.primaryUser = username;

  users.users.${username}.home = homeDirectory;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "before-home-manager";
  home-manager.users.${username} = {
    imports = [
      ../../modules/common
      {
        xdg.configFile."ghostty".source = ../../config/ghostty;

        # The cask's GUI app owns the macOS VPN extension. Expose its bundled
        # CLI on the standard Home Manager path without installing the
        # conflicting Homebrew formula.
        home.file.".local/bin/tailscale" = {
          text = ''
            #!/bin/sh
            exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
          '';
          executable = true;
        };

        # Open the app once at every login. Tailscale then starts its own
        # login helper and reconnects according to its saved session.
        launchd.agents.tailscale = {
          config = {
            ProgramArguments = [
              "/usr/bin/open"
              "-gj"
              "-a"
              "Tailscale"
            ];
            RunAtLoad = true;
          };
        };
      }
    ];

    home.username = username;
    home.homeDirectory = homeDirectory;
    home.stateVersion = homeStateVersion;
  };
}
