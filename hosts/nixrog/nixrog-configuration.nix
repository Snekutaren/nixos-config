# hosts/nixrog/nixrog-configuration.nix
# Main configuration file for the 'nixrog' NixOS machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    # ... (all your existing imports) ...
    ./nixrog-hardware-configuration.nix
    ./nixrog-users.nix
    ../../modules/common/common.nix
    #../../modules/common/sound.nix
    ../../modules/common/localization.nix
    #../../modules/common/display-manager.nix
    #../../modules/desktop/gnome.nix
    #../../modules/desktop/plasma.nix
    ../../modules/desktop/hyprland.nix
    #../../modules/desktop/deepin.nix
    #../../modules/services/monitoring.nix
  ];

  # ... host-specific settings ...
  networking.hostName = "nixrog";
  system.stateVersion = "25.05";

  services.displayManager.defaultSession = lib.mkForce "hyprland";

  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;
  # networking.useDHCP = lib.mkForce true; # remove, its in hardware.nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
#  boot.loader.systemd-boot.enable = true; # move to hardware
#  boot.loader.efi.canTouchEfiVariables = true; # this too

  # Enable sound with PipeWire
  #sound.enable = true;
  services.pulseaudio.enable = false; # Disable PulseAudio to avoid conflicts

  # Enable PipeWire and its components
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Optional, for 32-bit app support
    pulse.enable = true; # Enable PulseAudio compatibility
    jack.enable = true; # Optional, for JACK compatibility
    wireplumber.enable = true; # Enable WirePlumber session manager
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    pipewire
    wireplumber
    pavucontrol
    libpulseaudio
    alsa-utils # For aplay and amixer
    blueman
    #libcamera # Optional, for camera support
  ];

  # Enable UPower for WirePlumber
  services.upower.enable = true;

  # Enable xdg-desktop-portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Optional: Enable Bluetooth if needed
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  #  environment.systemPackages = with pkgs; [ blueman ]; # Optional, for GUI Bluetooth management

  services.pipewire.extraConfig.pipewire."10-disable-x11-bell" = {
  "load-module mod-x11-bell" = false;
  };

}
