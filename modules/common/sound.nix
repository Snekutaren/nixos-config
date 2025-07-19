# modules/common/sound.nix
{ config, pkgs, ... }:

{
  # Use PipeWire as the modern sound server
  services.pipewire = {
    enable = true;
    alsa.enable = true;          # ALSA compatibility
    pulse.enable = true;         # PulseAudio compatibility for older apps
    # jack.enable = true;        # Uncomment if you use JACK applications
  };

  # Enable RealtimeKit for better audio performance (PipeWire benefits from this)
  security.rtkit.enable = true;

  # Optionally, ensure PulseAudio is disabled if it was previously enabled elsewhere
  # (though PipeWire's pulse.enable usually handles this gracefully)
  services.pulseaudio.enable = false;
}