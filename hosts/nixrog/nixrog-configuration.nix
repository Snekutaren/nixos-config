# hosts/nixrog/nixrog-configuration.nix
# Main configuration file for the 'nixrog' NixOS machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    # Hardware-specific configuration for this machine.
    ./nixrog-hardware-configuration.nix

    # Host-specific user definitions.
    ./nixrog-users.nix

    # This will now be more general system settings, as localization is separate.
    ../../modules/common/common.nix
    # Audio configuration.
    ../../modules/common/sound.nix
    # Localization settings (timezone, keyboard layouts, locales).
    ../../modules/common/localization.nix
    # Display manager configuration (SDDM, handling multiple DEs).
    ../../modules/common/display-manager.nix

    # Desktop Environment modules (enable one or more to switch between).
    ../../modules/desktop/plasma.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/deepin.nix # Keep this if you want Deepin available
  ];

  # Host-specific settings (unique to 'nixrog').
  networking.hostName = "nixrog";
  system.stateVersion = "25.05";

  # Basic system services.
  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # Networking (if not handled by NetworkManager alone or requires specific settings).
  networking.useDHCP = lib.mkForce true; # Force DHCP

  # Nix-specific settings.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader configuration.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}