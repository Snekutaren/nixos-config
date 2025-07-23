# modules/common/common.nix
# General system-wide settings that apply to most NixOS installations.

{ config, pkgs, lib, ... }:

{
  # Enable D-Bus, essential for inter-process communication in desktop environments.
  services.dbus.enable = true;

  # Enable NetworkManager for graphical and command-line network management.
  networking.networkmanager.enable = true;

  # Common system-wide packages (CLI tools, etc.).
  environment.systemPackages = with pkgs; [
    neovim
    htop
    pciutils
    usbutils
    udisks2
    kdePackages.kate
    kdePackages.dolphin
    upower
    superfile
    helvum
    pavucontrol
    tmux
    bc
  ];

}
