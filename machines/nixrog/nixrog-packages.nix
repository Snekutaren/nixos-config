#nixos-config/machines/nixrog/nixrog-packages.nix
{ pkgs, inputs, ... }:
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
    #neovim
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
    #libsForQt5.qt5ct       # Qt5 theme configurator
    #qt6ct       # Qt6 theme configurator
    #kdePackages.breeze-qt5 # Example theme for Qt5
    #kvantum-qt5 # Optional, for Kvantum themes
    blueman
    upower
    mako
    # test
    lutris
    wine
    qemu
    telegram-desktop
    kdePackages.kcalc
    bridge-utils
    # Other dependencies like language servers
    lunarvim
    ripgrep
    fd
    # Secrets management
    inputs.agenix.packages.${pkgs.system}.agenix
    # Attic
    #inputs.attic.packages.${pkgs.system}.attic
    bash-language-server
  ];
}
