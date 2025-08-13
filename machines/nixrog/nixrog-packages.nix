#nixos-config/machines/nixrog/nixrog-packages.nix
{ config, pkgs, inputs, lib, ... }:
{
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
    trash-cli
    lm_sensors
    sysstat
    pv
    btop
    inotify-tools
    neofetch
    htop
    lsof
    strace
    pciutils
    usbutils
    udisks2
    parted
    gparted
    dos2unix
    tree
    eza
    qrencode
    dnsutils
    fd
    ntfs3g
    f3
    e2fsprogs
    fio
    # Networking
    iperf3
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
    # Build Beam MP Launcher
    vcpkg
    cmake
    gcc
    clang
    perl
    pkg-config
    gnumake
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
    # test
    lutris
    wine
    qemu
    bridge-utils
    # Secrets management
    inputs.agenix.packages.${pkgs.system}.agenix
    # Attic
    #inputs.attic.packages.${pkgs.system}.attic
  ];
}
