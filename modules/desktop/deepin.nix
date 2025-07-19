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
  environment.systemPackages = with pkgs; [
    # deepin.deepin-terminal
    # deepin.deepin-file-manager
  ];

  # REMOVED:
  # - services.xserver.enable (now in common.nix)
  # - services.xserver.displayManager.lightdm.enable (now in display-manager.nix)
  # - Audio config (now in modules/common/sound.nix)
  # - services.dbus.enable (now in common.nix)
  # - networking.networkmanager.enable (now in common.nix)
  # - Keyboard/Timezone (now in common.nix or common/localization.nix)
}