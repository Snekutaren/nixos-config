# modules/desktop/plasma.nix
# Configures the KDE Plasma 6 Desktop Environment.

{ config, pkgs, ... }:

{
  # Enable Plasma 6 desktop environment.
  services.desktopManager.plasma6.enable = true;

  # Ensure Qt apps theme correctly in Plasma.
  qt = {
    enable = true;
    platformTheme = "kde";
  };

  # Optional: Install some common KDE applications.
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.spectacle
    kdePackages.plasma-pa
  ];

  # REMOVED:
  # - services.xserver.enable (now in common.nix)
  # - services.displayManager.sddm.enable (now in display-manager.nix)
  # - Audio config (now in modules/common/sound.nix)
}