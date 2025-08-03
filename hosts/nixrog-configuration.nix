{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./nixrog-hardware-configuration.nix
    ../modules/networking.nix
    ../modules/sound.nix
    ../modules/localization.nix
    ../modules/hyprland.nix
    ../modules/backup.nix
  ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";

  programs.bash = {
    enable = true;

    shellAliases = {
      ll = "ls -lah";
      lR = "ls -laR";
      lRl = "ls -laR | less";
      comfyui = "nix develop ~/comfyui/nix";
    };

    extraInit = ''
      export PATH="$HOME/.local/bin:$PATH"
      
      # Define complex commands as functions.
      # The "ssha" alias as a function.
      function ssha() {
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/github/github_ed25519
      }

      # The "git-push" aliases as functions for clarity.
      # Note: The '|| true' part is fine, but you should handle
      # the command chain as a single function.
      function git-push-nixos() {
        local config_dir="$HOME/nixos-config"
        git -C "$config_dir" checkout auto
        git -C "$config_dir" add .
        git -C "$config_dir" commit -m "$(date)" || true
        git -C "$config_dir" push
      }

      function git-push-dot() {
        local config_dir="$HOME/dotfiles"
        git -C "$config_dir" checkout auto
        git -C "$config_dir" add .
        git -C "$config_dir" commit -m "$(date)" || true
        git -C "$config_dir" push
      }

      function git-push-comfyui() {
        local config_dir="$HOME/comfyui"
        git -C "$config_dir" checkout auto
        git -C "$config_dir" add .
        git -C "$config_dir" commit -m "$(date)" || true
        git -C "$config_dir" push
      }
      
      # The "push-build-nix" alias as a function.
      function update-flake() {
        sudo nix flake update --flake ~/nixos-config -v
      }
      function build-nix() {
        sudo nixos-rebuild switch --flake ~/nixos-config -v
      }
      function push-build-nix() {
        update-flake
        git-push-nixos
        git-push-dot
        build-nix
      }

      # The "reload-conf" alias as a function.
      # On NixOS, sourcing ~/.bashrc is often unnecessary.
      # Hyprland reload should be a separate command.
      function reload-conf() {
        echo "Bash configuration reloaded."
        hyprctl reload
        echo "Hyprland configuration reloaded."
      }
    '';
  };

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