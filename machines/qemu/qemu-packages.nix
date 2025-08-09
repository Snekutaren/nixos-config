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
    neofetch htop lsof strace pciutils usbutils udisks2 gparted dos2unix tree eza

    # Networking
    wget curl cifs-utils sshpass dnsutils

    # Development
    git neovim tmux jq bc

    # GUI utilities
    upower mako

    # Secrets management
    inputs.agenix.packages.${pkgs.system}.agenix
  ];
}
