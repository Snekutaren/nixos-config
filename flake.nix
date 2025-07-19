{
  description = "NixOS config with Deepin";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        rog = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/rog.nix
          ];
          pkgs = pkgs;
        };
      };
    };
}