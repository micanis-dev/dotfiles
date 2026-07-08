{
  username,
  homeDirectory,
  homeStateVersion,
  ...
}:
{
  imports = [
    ../../modules/nixos
  ];

  networking.hostName = "nixos";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${username} = {
    imports = [
      ../../modules/common
      ../../modules/linux
    ];

    home.username = username;
    home.homeDirectory = homeDirectory;
    home.stateVersion = homeStateVersion;
  };
}
