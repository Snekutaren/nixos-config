# modules/common/localization.nix
{ config, pkgs, ... }:

{
  # System-wide locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # You can add more supported locales if needed, e.g., for specific applications
    # supportedLocales = [ "en_US.UTF-8/UTF-8" "sv_SE.UTF-8/UTF-8" ];
  };

  # Console (TTY) keyboard layout
  console.keyMap = "sv-latin1";

  # Graphical (X11) keyboard layout (often overridden by DEs, but good fallback)
  services.xserver.layout = "se";
  # Optional X server keyboard options, e.g., to enable Ctrl+Alt+Backspace to kill X
  # services.xserver.xkbOptions = "terminate:ctrl_alt_bksp";

  # Set your system's timezone
  time.timeZone = "Europe/Stockholm";
}