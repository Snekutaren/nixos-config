{ config, pkgs, ... }:

{
    # Hyprland NixOS Module
    programs.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Flake Inputs -> Hyprland Package
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    


    environment.systemPackages = with pkgs; [
      hyprpaper
      kitty
      libnotify
      mako
      qt5.qtwayland
      qt6.qtwayland
      rofi
      swayidle
      swaylock-effects
      wlogout
      wl-clipboard
      wofi
      waybar
      hyprlock
    ];
}
