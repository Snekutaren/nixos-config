{ config, pkgs, nurPkgs, lib, ... }:
{
  imports = [
    ./nixrog-hardware-configuration.nix
    ../modules/networking.nix
    ../modules/sound.nix
    ../modules/localization.nix
    ../modules/hyprland.nix
  ];

  # ... host-specific settings ...

  system.stateVersion = "25.05"; # Matching the NixOS release branch
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Enable experimental features for Nix
  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  services.displayManager.defaultSession = lib.mkForce "hyprland"; # Set Hyprland as the default session
  services.openssh.enable = true; # Enable SSH server
  services.dbus.enable = true; # Enable D-Bus for inter-process communication
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.blueman.enable = true; # Enable Blueman for Bluetooth management
  services.upower.enable = true; # Enable UPower for power management

  security.sudo.enable = true; # Enable sudo for all users
  security.sudo.wheelNeedsPassword = true; # Require password for sudo in the wheel group

  # Game mode for performance tuning  
  programs.gamemode.enable = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    baobab     # Best native choice
    kdePackages.filelight  # Optional: visual ring style
    qdirstat         # Optional: feature-rich tree map
    inputs.agenix.packages.${pkgs.system}.agenix # Agenix for secret management
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
    peazip        # For file compression
    ncdu          # For disk usage analysis
    superfile     # For file management
    neovim        # Modern text editor
    kdePackages.kio # KDE I/O slaves
    tree       # For displaying directory structure
    eza     # For enhanced file listing
    sshpass   # For non-interactive SSH password input
    file   # For file type identification
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
    tmux # Terminal multiplexer
    bc # For arbitrary precision arithmetic
    #xdg-user-dirs # For managing user directories
    xdg-utils     # For desktop integration
    rocmPackages.rocminfo # ROCm information tool
    rocmPackages.rocm-smi # ROCm System Management Interface
    #xdg-desktop-portal # For desktop portal support
    #xdg-desktop-portal-gtk # GTK support for desktop portal
    #xdg-desktop-portal-kde # KDE support for desktop portal
    # ] ++ (with pkgs; [
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

  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ]; # 'networkmanager' for GUI network control
    password = "password"; # WARNING: Use a hash or set post-install in production!
  };
}
