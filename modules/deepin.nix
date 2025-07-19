# deepin.nix
# This file defines the Deepin Desktop Environment configuration.

{ config, pkgs, lib, ... }:

{
  # Ensure the X server is enabled, as Deepin runs on X.
  services.xserver.enable = true;

  # Enable the Deepin Desktop Environment (DDE) itself.
  # This option is designed to pull in all necessary DDE components,
  # including the dock, session manager, and other core Deepin applications.
  services.xserver.desktopManager.deepin.enable = true;

  # Display Manager: LightDM is a common and well-supported choice for DDE.
  # The Deepin module should correctly configure LightDM to use the DDE session.
  services.xserver.displayManager.lightdm.enable = true;
  # Optional: Configure LightDM's greeter if desired.
  # services.xserver.displayManager.lightdm.greeters.gtk.enable = true;
  # services.xserver.displayManager.lightdm.greeters.gtk.theme.name = "Adwaita";
  # services.xserver.displayManager.lightdm.greeters.gtk.extraCss = ''
  #   #greeter { background-image: url("${pkgs.deepin.deepin-wallpapers}/share/wallpapers/dde_backgrounds/deepin_wallpaper_default.png"); background-size: cover; }
  # '';

  # --- Fonts ---
  # Corrected: 'fonts.fonts' has been renamed to 'fonts.packages'.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans # Often good for broader language support
    noto-fonts-emoji # For emoji support
    # Add any other fonts you prefer, e.g.,
    # dejavu_fonts
  ];

  # --- Audio Configuration (Modern NixOS) ---
  # Corrected: 'hardware.pulseaudio' has been renamed to 'services.pulseaudio'.
  services.pulseaudio.enable = false;

  # Enable PipeWire, including its PulseAudio compatibility layer
  # (so applications expecting PulseAudio will still work).
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Enable ALSA support
    pulse.enable = true; # Enable PulseAudio compatibility
    # jack.enable = true; # Enable JACK compatibility (if you use JACK apps)
  };

  # Real-time priority for audio processing (recommended for PipeWire)
  security.rtkit.enable = true;

  # --- System Packages (if you specifically need some Deepin-related tools) ---
  # Only add packages here if they are *not* automatically pulled in by
  # services.xserver.desktopManager.deepin.enable and you specifically need them.
  # Explicitly adding core DDE components like dde-dock here is usually
  # redundant and can sometimes interfere.
  environment.systemPackages = with pkgs; [
    # deepin.deepin-terminal # Example: if you want the Deepin Terminal
    # deepin.deepin-file-manager # Example: if you want the Deepin File Manager
    # deepin.dde-network-manager # This might be pulled in by default
  ];

  # --- Other common desktop-related settings you might want ---
  # Enable D-Bus (essential for desktop environments)
  services.dbus.enable = true;

  # Enable NetworkManager for network management
  networking.networkmanager.enable = true;

  # Set your desired keyboard layout permanently (e.g., for a Swedish keyboard)
  # services.xserver.layout = "se";
  # services.xserver.xkbOptions = "terminate:ctrl_alt_bksp"; # Optional: Ctrl+Alt+Backspace to kill X

  # Enable auto-login for your user (for a quick VM test)
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "yourusername"; # Replace with your user
}