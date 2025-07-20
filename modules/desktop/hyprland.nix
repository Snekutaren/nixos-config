# modules/desktop/hyprland.nix
# Configures the Hyprland Wayland compositor.

{ config, pkgs, ... }:

{
  # Enable Hyprland Wayland compositor.
  programs.hyprland.enable = true;

  # Enable XWayland compatibility layer for X11 applications.
  programs.hyprland.xwayland.enable = true;

  # Enable the XDG Desktop Portal for Hyprland (essential for screen sharing, Flatpak, etc.).
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Essential utilities for a functional Hyprland desktop.
  environment.systemPackages = with pkgs; [
    kitty        # A fast terminal emulator
    wofi         # An application launcher
    waybar       # A customizable Wayland status bar
    dunst        # Notification daemon
    #polkit-gnome # A Polkit agent for graphical authentication
    grim         # Screenshot tool
    slurp        # Region selection for grim
    wl-clipboard # Clipboard manager
    swaybg       # Simple Wayland background setter
    # hyprpaper    # Hyprland's own wallpaper option, if preferred
  ];

  # You can put your actual Hyprland configuration (keybindings, rules, animations)
  # here or, ideally, manage it with Home Manager.
  # For example:
  # programs.hyprland.settings = {
  #   "$mod" = "SUPER";
  #   bind = [
  #     "$mod, Q, killactive,"
  #     "$mod, M, exec, wofi --show drun"
  #     "$mod, RETURN, exec, kitty"
  #   ];
  # };

  # REMOVED:
  # - services.xserver.enable (now in common.nix)
  # - Audio config (now in modules/common/sound.nix)
}
