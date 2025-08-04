{ config, pkgs, inputs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #./nixrog-hardware-configuration.nix
    ../modules/networking.nix
    ../modules/localization.nix
    ../modules/sound.nix
    ../modules/backup.nix
    ../modules/hypr/hyprland.nix
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "cryptd" "cifs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    cryptroot = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_LUKS";
      preLVM = true; # Ensure LUKS is opened before LVM
      allowDiscards = true;
      # Uncomment if using a persistent keyfile managed by agenix
      # keyFile = "/etc/luks-keys/cryptroot.key";
    };
  };
  fileSystems."/" = {
    device = lib.mkForce "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = lib.mkForce "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.xone.enable = true;
  hardware.xpad-noone.enable = true;
  hardware.amdgpu = {
    amdvlk.enable = false;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  nix.settings.extra-sandbox-paths = [ "/dev/kfd" "/dev/dri/renderD128" ];

  # Ensures fileSystems entries are generated for regular nixos-rebuild (non-destructive).
  disko.enableConfig = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";

  # Display and video drivers
  services.displayManager.defaultSession = lib.mkForce "hyprland";
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Services
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