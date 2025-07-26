# flake.nix
{
  description = "NixROG 25.05";

  inputs = {
    # Primary Nixpkgs input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager input
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # For password management (Age/Agnix)
     agenix.url = "github:ryantm/agenix";

    # Hyprland input
    hyprland.url = "github:hyprwm/Hyprland";

    # Dotfiles input
    dotfiles = {
    url = "path:/home/owdious/git/dotfiles";
    };

  };

  outputs = { self, nixpkgs, agenix, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        nixrog = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          
          modules = [
            
            # Main configuration
            ./hosts/nixrog-configuration.nix
            ./hosts/nixrog-hardware-configuration.nix
            ./hosts/nixrog-users.nix
          
            # Integrate Home Manager
           home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.backupFileExtension = "backup";
            } 

            # Integrate Agenix
            agenix.nixosModules.default
            {
              age.identityPaths = [ "/home/owdious/.ssh/id_ed25519" ];
            }

            # Allow unfree packages
            ({ ... }: {
            nixpkgs.config.allowUnfree = true;
            })
            
          ];
        };
      };
    };
}
