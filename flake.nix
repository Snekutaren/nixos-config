{
  description = "NixROG - Consolidated Unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles.url = "path:/home/owdious/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          rocmTargets = [ "gfx1200" "gfx1201" ];
        };
      };
    in {
      nixosConfigurations.nixrog = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; }; # Removed pkgs from specialArgs
        modules = [
          # Use readOnlyPkgs to set nixpkgs.pkgs and suppress warning
          "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
          {
            nixpkgs.pkgs = pkgs;
          }
          ./hosts/nixrog-configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; }; # Removed pkgs from extraSpecialArgs
              users.owdious.imports = [ ./home/owdious/home.nix ];
            };
          }
          agenix.nixosModules.default {
            age.identityPaths = [ "/home/owdious/.ssh/id_ed25519" ];
          }
        ];
      };
    };
}