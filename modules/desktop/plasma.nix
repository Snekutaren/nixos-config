# modules/desktop/plasma.nix
# Configures the KDE Plasma 6 Desktop Environment.

{ config, pkgs, ... }:

{
  # Enable Plasma 6 desktop environment.
  services.desktopManager.plasma6.enable = true;
  # Ensure KWallet is enabled and integrated with PAM
  #services.kwallet.enable = true; # This should be enabled by default with Plasma, but good to check
  security.pam.services.sddm.enableKwallet = true; # Ensure SDDM PAM integrates with KWallet
  security.pam.services.login.enableKwallet = true; # For console logins too
  # If you also use GNOME apps that rely on gnome-keyring, you might need:
  #security.pam.services.sddm.enableGnomeKeyring = true;
  #security.pam.services.login.enableGnomeKeyring = true;

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
}
