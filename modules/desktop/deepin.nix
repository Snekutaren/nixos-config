# modules/desktop/deepin.nix
# Configures the Deepin Desktop Environment.

{ config, pkgs, lib, ... }:

{
  # Enable Deepin Desktop Environment (DDE).
  services.xserver.desktopManager.deepin.enable = true;

  # --- Fonts ---
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans # Noto CJK Sans fonts
    noto-fonts-emoji    # For emoji support
  ];

  # --- System Packages (Deepin-specific, if not pulled by DDE module) ---
  environment.systemPackages = [
    pkgs.deepin.dde-file-manager
    pkgs.deepin.dde-tray-loader
    pkgs.deepin.dde-launchpad     # Start menu (launcher)
    pkgs.deepin.dde-session-ui    # Session UI components
    pkgs.deepin.dde-control-center # Control center for settings
  ];
}
