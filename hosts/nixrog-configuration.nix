{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./nixrog-hardware-configuration.nix
    ../modules/networking.nix
    ../modules/sound.nix
    ../modules/localization.nix
    ../modules/hyprland.nix
  ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";

  # Display and video drivers
  services.displayManager.defaultSession = lib.mkForce "hyprland";
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Services
  services.openssh.enable = true;
  services.dbus.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true;

  # Security
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  # Performance
  programs.gamemode.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Disk usage tools
    baobab
    kdePackages.filelight
    qdirstat
    ncdu

  # Backup
    restic

  # Security
    age

    # File management
    superfile
    peazip
    unzip
    file
    kdePackages.dolphin
    kdePackages.kio
    kdePackages.kio-extras

    # System utilities
    neofetch
    htop
    lsof
    strace
    pciutils
    usbutils
    udisks2
    gparted
    dos2unix
    tree
    eza

    # Networking
    wget
    curl
    samba
    cifs-utils
    sshpass

    # Development
    git
    neovim
    tmux
    jq
    bc

    # Graphics and input
    vulkan-tools
    glxinfo
    evtest
    jstest-gtk
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    mangohud

    # GUI applications
    kdePackages.kate
    kdePackages.konsole
    blueman
    upower
    mako

    # Secrets management
    inputs.agenix.packages.${pkgs.system}.agenix
  ];

  # User configuration
  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    hashedPasswordFile = config.age.secrets.owdious.path;
  };
}