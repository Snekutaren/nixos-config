# modules/common/display-manager.nix
# Centralized display manager configuration.

{ config, pkgs, lib, ... }:

{
  # Enable SDDM as the display manager.
  # SDDM is excellent for handling multiple desktop environments and sessions
  # (X11 like Deepin, and Wayland like Plasma and Hyprland).
  services.displayManager.sddm = {
    enable = true;
    # Enable Wayland support for SDDM. This is crucial for launching
    # Wayland sessions (Plasma Wayland, Hyprland).
    wayland.enable = true;

    # Optional: Configure SDDM theming
    # This example uses the default SDDM theme. You can install custom themes
    # from nixpkgs (e.g., sddm-nordic-theme) and set them here.
    # theme = "elarun"; # Example: if you installed a theme named 'elarun'
    # package = pkgs.sddm-kcm; # SDDM configuration module for Plasma (optional)

    # Optional: Enable auto-login for a specific user. Use with caution!
    # This bypasses the login screen. Useful for single-user machines or VMs.
    # autoLogin = {
    #   enable = true;
    #   user = "owdious"; # Replace with your username
    #   # session = "plasmawayland"; # Optionally specify a default session for auto-login
    # };

    # Optional: Custom SDDM settings (see 'man sddm.conf' for more options)
    # This allows you to pass raw settings to SDDM's configuration file.
    # extraConfig = ''
    #   [Autologin]
    #   User=owdious
    #   Session=plasma.desktop
    # '';
  };

  # Optional: If you prefer LightDM or want to keep it as an option, you could
  # define it here instead of SDDM. But only one display manager should be active.
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.displayManager.lightdm.greeters.gtk.enable = true;
  # services.xserver.displayManager.lightdm.greeters.gtk.theme.name = "Adwaita";
}