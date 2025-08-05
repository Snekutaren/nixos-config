{ config, pkgs, lib, ... }:

{
    services.xserver.displayManager.lightdm.enable = true;
    services.displayManager.defaultSession = lib.mkForce "hyprland";

    # Hyprland NixOS Module
    programs.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Flake Inputs -> Hyprland Package
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

     # Enable xdg-desktop-portal for Hyprland
    xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    environment.systemPackages = with pkgs; [
      hyprlock
      hypridle
      hyprpaper
      kitty
      libnotify
      mako
      qt5.qtwayland
      qt6.qtwayland
      rofi
      wlogout
      wl-clipboard
      wofi
      waybar
      #wlr-randr
      wl-gammactl   # For managing screen gamma
      wlsunset      # For managing screen color temperature
    ];
}
