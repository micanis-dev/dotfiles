{
  description = "micanis dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      username = "micanis";
      homeStateVersion = "25.05";

      specialArgs = {
        inherit inputs username homeStateVersion;
      };

      forAllSystems =
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
          "x86_64-linux"
        ];

      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkHome =
        {
          system,
          hostModule,
          homeDirectory ? "/home/${username}",
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = specialArgs // {
            inherit homeDirectory;
          };
          modules = [ hostModule ];
        };
    in
    {
      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = specialArgs // {
          homeDirectory = "/Users/${username}";
        };
        modules = [
          ./hosts/darwin
          home-manager.darwinModules.home-manager
        ];
      };

      homeConfigurations = {
        linux-gui = mkHome {
          system = "x86_64-linux";
          hostModule = ./hosts/linux-gui/home.nix;
        };

        linux-headless = mkHome {
          system = "x86_64-linux";
          hostModule = ./hosts/linux-headless/home.nix;
        };
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs // {
          homeDirectory = "/home/${username}";
        };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              nixfmt-rfc-style
              nil
              statix
              deadnix
            ];
          };
        }
      );

      templates = {
        python = {
          path = ./templates/python;
          description = "Python devShell with nix-direnv";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust devShell with nix-direnv";
        };
        cpp = {
          path = ./templates/cpp;
          description = "C++ devShell with nix-direnv";
        };
      };
    };
}
