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
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = homeStateVersion;
}
