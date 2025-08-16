{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Disk usage tools
    baobab qdirstat ncdu

    # Backup
    restic

    # Security
    age

    # File management
    superfile peazip unzip file

    # System utilities
    neofetch htop lsof strace pciutils usbutils udisks2 gparted dos2unix tree eza neovim

    # Networking
    wget curl cifs-utils sshpass dnsutils

    # Development
    neovim tmux jq bc

    # GUI utilities
    upower mako

    #
    bash-language-server

    #
    lutris
    wine
    qemu
    telegram-desktop
    bridge-utils
    gamescope
    brave
    discord
    heroic
    steam
    vscode
    vlc
    playerctl
    thunderbird
    gimp
    libreoffice
    blender
    moonlight-qt
    steam-run
    pkgs.tabby
    chromium
    krita
    colobot
    docker

    # Secrets management
    inputs.agenix.packages.${pkgs.system}.agenix
    #inputs.attic.packages.${pkgs.system}.attic
  ];
}
