{
  description = "Consolidated Unstable + Stable";
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = { self, nixpkgs-unstable, nixpkgs-stable, home-manager-stable, home-manager-unstable, agenix, disko, ... }@inputs:
  let
    system = "x86_64-linux";
    nixrogPkgs = import nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
        rocmTargets = [ "gfx1201" ];
      };
    };
    qemuPkgs = import nixpkgs-stable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations.nixrog = nixpkgs-unstable.lib.nixosSystem {
      inherit system;
      pkgs = nixrogPkgs;
      specialArgs = { inherit inputs; pkgs = nixrogPkgs; };
      modules = [
        ./machines/nixrog/nixrog-config.nix
        disko.nixosModules.disko
        home-manager-unstable.nixosModules.home-manager
        agenix.nixosModules.default
      ];
    };
    nixosConfigurations.qemu = nixpkgs-stable.lib.nixosSystem {
      inherit system;
      pkgs = qemuPkgs;
      specialArgs = { inherit inputs; pkgs = qemuPkgs; };
      modules = [
        ./machines/qemu/qemu-config.nix
        disko.nixosModules.disko
        home-manager-stable.nixosModules.home-manager
        agenix.nixosModules.default
      ];
      #configuration = {
      #  isStable = true;  # Eller false om du vill unstable
      #};
    };
  };
}
