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
  home-manager.users.${username} = {
    imports = [
      ../../modules/common
    ];

    home.username = username;
    home.homeDirectory = homeDirectory;
    home.stateVersion = homeStateVersion;
  };
}
