{
  username,
  homeDirectory,
  homeStateVersion,
  ...
}:
{
  imports = [
    ../../modules/common
    ../../modules/linux/headless.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = homeStateVersion;
}
