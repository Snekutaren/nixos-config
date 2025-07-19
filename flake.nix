{
  description = "NixROG 25.05";

  inputs = {
    # Primary Nixpkgs input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager input
    home-manager.url = "github:nix-community/home-manager/release-23.11"; # Match your NixOS release if possible, or use 'master'/'main' for latest
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # Ensure Home Manager uses the same Nixpkgs as your system

    # For password management (Age/Agnix) - discussed below
    agenix.url = "github:ryantm/agenix"; # Or sops-nix for more general SOPS integration
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs: # Add all inputs you want to use in specialArgs here
    let
      system = "x86_64-linux";
      # No need for 'let pkgs = ...' here, nixosSystem will provide it
    in {
      nixosConfigurations = {
        nixrog = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; }; # <--- Pass all inputs to your modules for convenience

          modules = [
            ./hosts/nixrog/nixrog-configuration.nix

            # Integrate Home Manager as a NixOS module
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true; # Allow HM to use system-wide pkgs
              home-manager.useUserPackages = true; # Build user packages in separate store paths
              # Define where your Home Manager configuration for 'owdious' is located
              home-manager.users.owdious = import ./home/owdious/home.nix;
            }

            # Integrate Agenix for secrets management
            agenix.nixosModules.default
          ];

          # Define global nixpkgs options here
          config = {
            nixpkgs.config.allowUnfree = true;
          };
        };
      };
      # You can also define homeManagerConfigurations for standalone HM builds, etc.
      # homeManagerConfigurations.owdious = home-manager.lib.homeManagerConfiguration { ... };
    };
}