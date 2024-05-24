{
  description = "Anton's nix-darwin MBP M2Pro Mac configuration";

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs @ { self, nixpkgs-darwin, nixpkgs-unstable, darwin, home-manager, nix-index-database, ... }: let
    username = "anton";
    system = "aarch64-darwin";
    hostname = "${username}-mbp";
    specialArgs = inputs // {
      inherit username hostname system;
      pkgs = import nixpkgs-darwin {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };
      unstablePkgs = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
      };
    };

  in {
    darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/apps.nix
        ./modules/system.nix
        ./modules/fonts.nix
        ./modules/zsh.nix
        nix-index-database.nixosModules.nix-index
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username} = import ./home {
            pkgs = specialArgs.pkgs;
            unstablePkgs = specialArgs.unstablePkgs;
            username = specialArgs.username;
          };
        }
      ];
    };
  };
}

