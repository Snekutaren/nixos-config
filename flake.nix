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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #dotfiles.url = "path:/home/owdious/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager, agenix, disko, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { # necessary? just have it called nixpks?
        inherit system;
        config = {
          allowUnfree = true;
          rocmTargets = [ "gfx1201" ];
        };
      };
    in {
      nixosConfigurations.nixrog = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs; };
        modules = [
          disko.nixosModules.disko
          #./machines/nixrog/nixrog-disko.nix
          ./machines/nixrog/nixrog-config.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs pkgs; }; # necessary? just have it called nixpks - and import it with imputs here?
              users.owdious.imports = [ "/machines/nixrog/nixrog-home-owdious.nix" ];
            };
          }
          agenix.nixosModules.default {
            #age.secrets.owdious = {
            #  file = ./secrets/owdious.age;
            #  owner = "owdious"; # optional if you want to set ownership on decryption
            #};
            #age.secrets = import ./secrets/secrets.nix;
            age.identityPaths = [ "/home/owdious/.config/age/keys.txt" ];
          }
        ];
      };

      nixosConfigurations.qemu = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs; };
        modules = [
          disko.nixosModules.disko
          ./machines/qemu-config.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs pkgs; }; # necessary? just have it called nixpks - and import it with imputs here?
              users.qemu.imports = [ "./machines/qemu/qemu-home-qemu.nix" ];
            };
          }
          #agenix.nixosModules.default {
            #age.secrets.qemu = {
            #  file = ./secrets/qemu.age;
            #  owner = "qemu"; # optional if you want to set ownership on decryption
            #};
            #age.secrets = import ./secrets/secrets.nix;
            #age.identityPaths = [ "/home/qemu/.config/age/keys.txt" ];
          #}
        ];
      };

    };
}