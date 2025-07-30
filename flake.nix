{
  description = "NixROG - Consolidated Unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";


    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Age for secrets
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # NUR
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Local dotfiles
    dotfiles.url = "path:/home/owdious/git/dotfiles";

  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, nur, ... }: 
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      nurPkgs = nur.packages.${system};

    in {
      nixosConfigurations = {
        nixrog = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs nurPkgs;
            pkgs = pkgs;
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