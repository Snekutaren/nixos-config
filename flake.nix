{
  description = "NixROG 25.05";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        nixrog = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixrog/nixrog-configuration.nix
          ];
          pkgs = pkgs;
        };
      };
    };
}
