{ config, pkgs, lib, ... }:

{
  imports = [
    ./rog-hardware-configuration.nix
    ../modules/common.nix
    ../modules/deepin.nix
  ];

  networking.hostName = "rog";

  system.stateVersion = "25.05";

  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "password";
  };

  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # Force this to avoid conflicts
  networking.useDHCP = lib.mkForce true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ vim git htop ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
