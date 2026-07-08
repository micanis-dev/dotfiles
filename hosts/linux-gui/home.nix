{
  username,
  homeDirectory,
  homeStateVersion,
  ...
}:
{
  imports = [
    ../../modules/common
    ../../modules/linux
    ../../modules/linux/gui.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = homeStateVersion;
}
