{ config, pkgs, lib, ... }:
{
    services.displayManager.defaultSession = lib.mkForce "hyprland";
    programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    };
    xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
    environment.systemPackages = with pkgs; [
      hyprlock
      hypridle
      hyprpaper
      hyprshot
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
