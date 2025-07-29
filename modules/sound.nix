# modules/sound.nix
{ config, pkgs, ... }:

{
  # Enable PipeWire and its components
  services.pulseaudio.enable = false;   # Disable PulseAudio to avoid conflicts
  services.pipewire = {                 # PipeWire configuration
    enable = true;                      # Enable PipeWire
    alsa.enable = true;                 # Enable ALSA support
    alsa.support32Bit = true;           # Optional, for 32-bit app support
    pulse.enable = true;                # Enable PulseAudio compatibility
    jack.enable = true;                 # Optional, for JACK compatibility
    wireplumber.enable = true;          # Enable WirePlumber session manager
  };

  # Enable RealtimeKit for better audio performance (PipeWire benefits from this)
  security.rtkit.enable = true;

  # Tools for managing audio
  environment.systemPackages = with pkgs; [
    pipewire        # PipeWire media server
    wireplumber     # WirePlumber session manager
    pavucontrol     # PulseAudio volume control
    libpulseaudio   # For PulseAudio compatibility
    alsa-utils      # For aplay and amixer
    helvum          # For PipeWire graph visualization
    lollipop
  ];
}