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
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland"; # IMPORTANT

    dotfiles = {
    url = "path:/home/owdious/git/dotfiles";
    };

  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        nixrog = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
      
          modules = [
            # Main configuration
            ./hosts/nixrog/nixrog-configuration.nix
          
            home-manager.nixosModules.home-manager {
      	    home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.owdious = ./home/owdious/home.nix;
            home-manager.backupFileExtension = "backup";
#            users = {
#             owdious = {
#                imports = [
#                  ./home/owdious/home.nix
#                ];
#                home.stateVersion = "25.05"; # <--- THIS MUST BE HERE
#              };
#            };
          }  

#            users = {
#              owdious = {
#                imports = [
#                  ./home/owdious/home.nix
#                ];
#            home.stateVersion = "25.05"; # <--- THIS IS THE CORRECT PLACE FOR THIS OPTION FOR A USER
#              };
#            };

            # Integrate Agenix
            agenix.nixosModules.default

            # Define global nixpkgs options here
            {
              nixpkgs.config.allowUnfree = true;
	    }
	
            
          ];
        };
      };
    };
}
