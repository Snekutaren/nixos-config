{ config, inputs, pkgs, nurPkgs, lib, ... }:
{
  imports = [
    ./nixrog-hardware-configuration.nix
    ../modules/sound.nix
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
  #nixpkgs.config.allowUnfree = true; # Allow unfree packages
  services.dbus.enable = true; # Enable D-Bus for inter-process communication
  networking.networkmanager.enable = true; # Enable NetworkManager for network management

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

  #environment.sessionVariables = {
  #  NIXOS_OZONE_WL = "1";
  #};

  # System-wide packages
  environment.systemPackages = with pkgs; [
    baobab     # Best native choice
    kdePackages.filelight  # Optional: visual ring style
    qdirstat         # Optional: feature-rich tree map
    inputs.agenix.packages.${pkgs.system}.agenix # Agenix for secret management
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
    mako          # Notification daemon
    jq            # For JSON processing
    curl          # For transferring data with URLs
    unzip         # For extracting zip files
    evtest        # For testing input devices
    jstest-gtk    # For joystick testing
    wl-gammactl   # For managing screen gamma
    wlsunset      # For managing screen color temperature
    peazip        # For file compression
    ncdu          # For disk usage analysis
    superfile     # For file management
    neovim        # Modern text editor
    kdePackages.kio # KDE I/O slaves
    #kdePackages.kioFuse # FUSE support for KDE I/O slaves
    #kdePackages.kioFusePlugins # Additional FUSE plugins for KDE I/O slaves
    #kdePackages.kioTrash # Trash support for KDE I/O slaves
    #kdePackages.kioFileMetadata # File metadata support for KDE I/O slaves
    #kdePackages.kioGdrive # Google Drive support for KDE I/O slaves
    #kdePackages.kioFtp # FTP support for KDE I/O slaves
    #kdePackages.kioWebdav # WebDAV support for KDE I/O slaves
    #kdePackages.kioSftp # SFTP support for KDE I/O slaves
    #kdePackages.kioDolphin # Dolphin file manager support for KDE I/O slaves
    kdePackages.kio-extras  # Additional KDE I/O extras
    #kdenetworkPackages.kget # Download manager
    htop        # Interactive process viewer
    pciutils  # For lspci command
    usbutils  # For lsusb command
    udisks2 # For managing disks and storage devices
    lsof      # For listing open files
    strace    # For tracing system calls
    gparted   # For partition management
    kdePackages.kate # Advanced text editor
    kdePackages.konsole # Terminal emulator
    kdePackages.dolphin # File manager
    upower # For power management
    superfile # For file management
    helvum # For PipeWire graph visualization
    pavucontrol # For managing audio streams
    tmux # Terminal multiplexer
    bc # For arbitrary precision arithmetic
    #xdg-user-dirs # For managing user directories
    xdg-utils     # For desktop integration
    #xdg-desktop-portal # For desktop portal support
    #xdg-desktop-portal-gtk # GTK support for desktop portal
    #xdg-desktop-portal-kde # KDE support for desktop portal
    #xdg-desktop-portal-hyprland # Hyprland support for desktop portal
    # ] ++ (with unstablePkgs; [
    #neovim
    #vulkan-tools
    #mesa
    #mesa.drivers
    #rocmPackages.rocminfo
    #clinfo
    #rocmPackages.rocm-smi
  #]) ++ (with nurPkgs.repos.mic92; [
    #nixpkgs-review
  ];
  

  # Enable UPower for WirePlumber
  services.upower.enable = true;

  # Game mode for performance tuning  
  programs.gamemode.enable = true;

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

  # Enable AMD Vulkan driver (AMDVLK instead of Mesa RADV) # Witcher3 Wont runwith AMDVLK
  # Note: AMDVLK is not recommended for all games, RADV is often preferred
  hardware.amdgpu = {
    amdvlk.enable = false;
  };


  # Correct and current way to enable 32-bit graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  #hardware.opengl.enable = true;

  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio"]; # 'networkmanager' for GUI network control
    password = "password"; # WARNING: Use a hash or set post-install in production!
  };
}
