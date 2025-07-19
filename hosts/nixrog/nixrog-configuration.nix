# hosts/rog/configuration.nix
# Main configuration file for the 'rog' NixOS machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    # Hardware-specific configuration for this machine.
    ./nixrog-hardware-configuration.nix

    # Common system-wide settings (networking, core services, basic packages, localization).
    ../modules/common/common.nix

    # Audio configuration.
    ../modules/common/sound.nix

    # Display manager configuration (SDDM, handling multiple DEs).
    ../modules/common/display-manager.nix

    # Desktop Environment modules (enable one or more to switch between).
    ../modules/desktop/plasma.nix
    ../modules/desktop/hyprland.nix
    ../modules/desktop/deepin.nix # Keep this if you want Deepin available

    # Add other common modules here, e.g., for users if not in common.nix
    # ../modules/common/users.nix
  ];

  # Host-specific settings (unique to 'rog').
  networking.hostName = "rog";
  system.stateVersion = "25.05"; # <--- IMPORTANT: Ensure this matches your actual NixOS system version.

  # User definition (if not in a common user module).
  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # 'networkmanager' for GUI network control
    password = "password"; # WARNING: Use a hash or set post-install in production!
  };

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