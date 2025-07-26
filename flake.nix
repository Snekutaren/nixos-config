{
  description = "NixROG 25.05";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";

    hyprland.url = "github:hyprwm/Hyprland";

    dotfiles.url = "path:/home/owdious/git/dotfiles";
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
            ./hosts/nixrog-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.backupFileExtension = "backup";
            } 
            agenix.nixosModules.default
            {
              age.identityPaths = [ "/home/owdious/.ssh/id_ed25519" ];
            }
            {
              nixpkgs.config.allowUnfree = true;
            } 
          ];
        };
      };
    };
}

  