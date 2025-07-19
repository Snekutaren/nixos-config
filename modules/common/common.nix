# modules/common.nix
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

  # Set your system's timezone.
  time.timeZone = "Europe/Stockholm"; # From current context

  # System-wide locale settings.
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "sv_SE.UTF-8/UTF-8" ]; # If you need more

  # Console (TTY) keyboard layout.
  console.keyMap = "sv-latin1"; # Swedish keyboard layout for TTYs

  # General X11 keyboard layout (can be overridden by DEs but good for fallback/consistency).
  services.xserver.layout = "se";
  # Optional X server keyboard options, e.g., to enable Ctrl+Alt+Backspace to kill X.
  # services.xserver.xkbOptions = "terminate:ctrl_alt_bksp";

  # Common system-wide packages (CLI tools, etc.).
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  # You can also move your user definition here if it's common across machines
  # (though user passwords often vary per machine, so it's sometimes kept in host config).
  # users.users.owdious = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" "networkmanager" ];
  #   password = "password"; # Highly recommend using hashed passwords or Home Manager
  # };
}