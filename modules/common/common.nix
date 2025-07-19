# modules/common/common.nix
# General system-wide settings that apply to most NixOS installations.

{ config, pkgs, lib, ... }:

{
  # Enable the X server. This is fundamental for any graphical environment
  # (even Wayland compositors use XWayland for X11 application compatibility).
  services.xserver.enable = true;

  # Enable D-Bus, essential for inter-process communication in desktop environments.
  services.dbus.enable = true;

  # Enable NetworkManager for graphical and command-line network management.
  networking.networkmanager.enable = true;

  # Allow unfree packages (e.g., proprietary drivers, Steam, certain fonts).
  nixpkgs.config.allowUnfree = true;

  # Common system-wide packages (CLI tools, etc.).
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];