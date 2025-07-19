{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;

    desktopManager.deepin.enable = true;

    windowManager = {
      default = "deepin";
      deepin.enable = true;
    };
  };

  services.displayManager.lightdm.enable = true;
  services.displayManager.default = "lightdm";

  environment.systemPackages = with pkgs; [
    deepin.com.deepin.dde-dock
    deepin.com.deepin.dde-session-ui
  ];

  fonts.fonts = with pkgs; [ noto-fonts ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;
}
