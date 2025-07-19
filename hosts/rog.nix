{ config, pkgs, ... }:

{
  imports = [
    ./rog-hardware-configuration.nix
    ../modules/common.nix
    ../modules/deepin.nix
  ];

  networking.hostName = "rog";

  system.stateVersion = "25.05";

  # Your user
  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # Use hashedPassword in production!
    password = "password";
  };

  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  networking.useDHCP = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ vim git htop ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
