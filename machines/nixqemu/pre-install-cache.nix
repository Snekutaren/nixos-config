# nixos-config/modules/pre-install-cache.nix
{ config, pkgs, ... }:

{
  nix.settings = {
    substituters = [
      "http://10.0.20.100:5000?priority=1"
      "https://cache.nixos.org?priority=10"
    ];
    trusted-public-keys = [
      "truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };
}