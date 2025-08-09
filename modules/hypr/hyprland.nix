{ config, pkgs, lib, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = false; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  environment.systemPackages = with pkgs; [
    hyprshot
    hyprlock # Hyprland's GPU-accelerated screen locking utility.
    hypridle # Hyprland's idle daemon.
    hyprpaper # Hyprland's wallpaper utility.
    hyprsunset # Application to enable a blue-light filter on Hyprland.
    hyprpicker # Wayland color picker that does not suck.
    hyprpolkitagent # Polkit authentication agent written in QT/QML.
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
    #theme packages
    kdePackages.qtstyleplugin-kvantum
    catppuccin-gtk
    catppuccin-kvantum
    catppuccin-cursors
    catppuccin-papirus-folders
    #papirus-icon-theme
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    WLR_NO_HARDWARE_CURSORS = "0";
    GTK_THEME = "Catppuccin-Mocha-Standard-Lavender-Dark";
    QT_STYLE_OVERRIDE = "kvantum";
    XCURSOR_THEME = "Catppuccin-Mocha-Dark-Cursors";
    XCURSOR_SIZE = "24";
  };
  systemd.user.services.hyprland = {
    description = "Hyprland Wayland Compositor";
    after = [ "graphical.target" "dbus.service" ];
    wants = [ "dbus.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStartPre = [
        "/bin/sh -c 'until [ -d /home/owdious/.config ]; do sleep 0.5; done'"
        "/bin/sh -c 'until [ -r /home/owdious/.config/hypr/hyprland.conf ]; do sleep 0.5; done'"
        "/bin/sh -c 'until pgrep -x dbus-daemon > /dev/null; do sleep 0.5; done'"
      ];
      ExecStart = "${pkgs.hyprland}/bin/Hyprland";
      Restart = "always";
      RestartSec = "2";
      WorkingDirectory = "/home/owdious";
      Environment = [
        "HOME=/home/owdious"
        "PATH=/home/owdious/.local/bin:/run/wrappers/bin:/home/owdious/.nix-profile/bin:/nix/profile/bin:/home/owdious/.local/state/nix/profile/bin:/etc/profiles/per-user/owdious/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        "XDG_SESSION_TYPE=wayland"
        "XDG_CONFIG_HOME=/home/owdious/.config"
        "XDG_DATA_HOME=/home/owdious/.local/share"
        "XDG_CACHE_HOME=/home/owdious/.cache"
      ];
      StandardOutput = "journal";
      StandardError = "journal";
   };
  };
}
