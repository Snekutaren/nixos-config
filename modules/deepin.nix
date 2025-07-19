{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  services.xserver.desktopManager.deepin.enable = true;

  services.xserver.windowManager.default = "deepin";

  services.displayManager.lightdm.enable = true;
  services.displayManager.default = "lightdm";

  environment.systemPackages = with pkgs; [
    deepin.com.deepin.dde-dock
    deepin.com.deepin.dde-session-ui
  ];

  fonts.fonts = with pkgs; [ noto-fonts ];

  sound.enable = true;

  # Disable PulseAudio and enable PipeWire with PulseAudio compatibility
  hardware.pulseaudio.enable = false;

  hardware.pipewire = {
    enable = true;
    pulse = {
      enable = true;
    };
  };
}
