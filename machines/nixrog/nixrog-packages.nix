#nixos-config/machines/nixrog/nixrog-packages.nix
{ config, pkgs, inputs, lib, attic, ... }:
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
    inotify-tools
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
    qrencode
    dnsutils
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
    # Attic
    attic.packages.${pkgs.system}.attic
  ];
}
