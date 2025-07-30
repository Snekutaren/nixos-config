{
  description = "NixROG 25.05";

  inputs = {
    # Stable nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (stable)
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Age for secrets
    agenix.url = "github:ryantm/agenix";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";

    # NUR
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Local dotfiles
    dotfiles.url = "path:/home/owdious/git/dotfiles";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, nur, ... }@inputs:
    let
      system = "x86_64-linux";

      # Base pkgs (from stable)
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Unstable pkgs
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
       config.allowUnfree = true;
      };

      nurPkgs = nur.packages.${system};

    in {
      nixosConfigurations = {
        nixrog = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs pkgs nurPkgs;
          };

          modules = [
            ./hosts/nixrog-configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs pkgs nurPkgs;
                };
                users.owdious = {
                  imports = [
                    ./home/owdious/home.nix
                  ];
                };
              };
            }

            agenix.nixosModules.default
            {
              age.identityPaths = [ "/home/owdious/.ssh/id_ed25519" ];
            }
          ];
        };
      };
    };
}
