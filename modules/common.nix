{ config, pkgs, ... }:

{
  # Common stuff here, e.g. locale, time zone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Stockholm";

  # Loadkeys for Swedish-latin1 on all hosts
  console = {
    keyMap = "sv-latin1";
  };
}
