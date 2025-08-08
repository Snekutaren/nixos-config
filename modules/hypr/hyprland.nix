{ config, pkgs, lib, ... }:
{
  #services.displayManager.defaultSession = lib.mkForce "hyprland";
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Remove the systemd service - we'll start Hyprland from shell profile instead

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
    wl-gammactl
    wlsunset
    kdePackages.qtstyleplugin-kvantum
    catppuccin-gtk
    catppuccin-kvantum
    catppuccin-cursors
    catppuccin-papirus-folders
    #papirus-icon-theme
  ];

  # Set environment variables system-wide for Wayland
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    WLR_NO_HARDWARE_CURSORS = "0";
    GTK_THEME = "Catppuccin-Mocha-Standard-Lavender-Dark";
    QT_STYLE_OVERRIDE = "kvantum";
    XCURSOR_THEME = "Catppuccin-Mocha-Dark-Cursors";
    XCURSOR_SIZE = "24";
  };

  # Auto-start Hyprland on TTY1 login
  environment.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      exec Hyprland
    fi
  '';
}