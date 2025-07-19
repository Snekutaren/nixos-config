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
    # pkgs.deepin-terminal          # <--- REMOVED THIS LINE for now, as it was not found
    pkgs.deepin.dde-file-manager  # <--- CORRECTED THIS LINE with the found name
  ];

  # REMOVED: ...
}