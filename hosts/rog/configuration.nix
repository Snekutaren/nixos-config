{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "rog";

  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "password";
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [ vim git htop ];

  networking.useDHCP = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
