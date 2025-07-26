{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./nixrog-hardware-configuration.nix
    ../modules/common/localization.nix
    ../modules/desktop/hyprland.nix
  ];

  # ... host-specific settings ...
  networking.hostName = "nixrog"; # Set the hostname
  system.stateVersion = "25.05"; # Matching the NixOS release branch
  services.displayManager.defaultSession = lib.mkForce "hyprland"; # Set Hyprland as the default session
  services.openssh.enable = true; # Enable SSH server
  security.sudo.enable = true; # Enable sudo for all users
  security.sudo.wheelNeedsPassword = true; # Require password for sudo in the wheel group
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Enable experimental features for Nix
  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  services.dbus.enable = true; # Enable D-Bus for inter-process communication
  networking.networkmanager.enable = true; # Enable NetworkManager for network management
  #services.udev.packages = [ pkgs.xone ];
  hardware.xone.enable = true;

  # Enable PipeWire and its components
  services.pulseaudio.enable = false; # Disable PulseAudio to avoid conflicts
  services.pipewire = {  # PipeWire configuration
    enable = true; # Enable PipeWire
    alsa.enable = true; # Enable ALSA support
    alsa.support32Bit = true; # Optional, for 32-bit app support
    pulse.enable = true; # Enable PulseAudio compatibility
    jack.enable = true; # Optional, for JACK compatibility
    wireplumber.enable = true; # Enable WirePlumber session manager
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default # Agenix for secret management
    pipewire      # PipeWire media server
    wireplumber   # WirePlumber session manager
    pavucontrol   # PulseAudio volume control
    libpulseaudio # For PulseAudio compatibility
    alsa-utils    # For aplay and amixer
    blueman       # bluetooth GUI management
    vulkan-tools  # For Vulkan support
    glxinfo       # For OpenGL information
    dos2unix      # For converting text files
    cifs-utils    # For CIFS/SMB support
    neofetch      # For system information
    samba         # For SMB/CIFS support
    restic        # Backup too
    git           # Version control system
    wget          # For downloading files
    jq            # For JSON processing
    curl          # For transferring data with URLs
    unzip         # For extracting zip files
    evtest        # For testing input devices
    jstest-gtk    # For joystick testing
    #xone          # For Xbox controller support
    #xdg-user-dirs # For managing user directories
    xdg-utils     # For desktop integration
    #xdg-desktop-portal # For desktop portal support
    #xdg-desktop-portal-gtk # GTK support for desktop portal
    #xdg-desktop-portal-kde # KDE support for desktop portal
    #xdg-desktop-portal-hyprland # Hyprland support for desktop portal
  ];

  # Enable UPower for WirePlumber
  services.upower.enable = true;

  # Enable xdg-desktop-portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pipewire.extraConfig.pipewire."10-disable-x11-bell" = {
  "load-module mod-x11-bell" = false;
  };

  # Correct and current way to enable 32-bit graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio"]; # 'networkmanager' for GUI network control
    password = "password"; # WARNING: Use a hash or set post-install in production!
  };
}
