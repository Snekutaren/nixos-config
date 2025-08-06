#nixos-config/flake.nix
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
  };
  outputs = { self, nixpkgs, home-manager, agenix, disko, ... }@inputs:
  let
    system = "x86_64-linux";
    nixrogPkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        rocmTargets = [ "gfx1201" ];
      };
    };
    qemuPkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      #sharedModules = import ./modules/common.nix;
    };
  in {
    nixosConfigurations.nixrog = nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = nixrogPkgs;
      specialArgs = { inherit inputs; pkgs = nixrogPkgs; };
      modules = [
        ./machines/nixrog/nixrog-config.nix
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default 
      ];
    };
    nixosConfigurations.qemu = nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = qemuPkgs;
      specialArgs = { inherit inputs; pkgs = qemuPkgs; };
      modules = [
        ./machines/qemu/qemu-config.nix
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
