# home/owdious/home.nix
{ config, pkgs, inputs, lib, ... }:

{
  # Restore home-manager state
  home.stateVersion = "25.05"; # Matching the home-manager release branch

  # Set default editor
  home.sessionVariables.EDITOR = "nvim";

  # Home Manager needs to know your user's home directory
  home.homeDirectory = "./home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    brave
    git
    discord
    heroic
    steam
    vscode
    kdePackages.kio
    kdePackages.kio-extras
    neovim
    htop
    pciutils
    usbutils
    udisks2
    kdePackages.kate
    kdePackages.dolphin
    upower
    superfile
    helvum
    pavucontrol
    tmux
    bc
  ];

  # Enable a shell (e.g., Zsh)
  programs.zsh = {
    enable = true;
    # Temporarily removed ohMyZsh to debug "option does not exist" error.
    # It will be re-added or corrected once the base Zsh setup works.
    # ohMyZsh.enable = true; # Example: Enabling Oh My Zsh  <-- THIS LINE MUST BE COMMENTED/REMOVED
  };

  # Enable Git configuration
  programs.git = {
    enable = true;
    userName = "Snekutaren";
    userEmail = "snekutaren@gmail.com";
  };

  programs.eww = {
    enable = true;
  };

# home.manager.backupFileExtension = "backup";

home.activation.removeDotfileConflicts = lib.hm.dag.entryBefore ["checkFilesChanged"] ''
  date="$$(date +%Y-%m-%d_%H-%M-%S)"

  files=(
    "$${HOME}/.config/hypr/hyprland.conf"
    "$${HOME}/.config/hypr/scripts/toggle_scroll.sh"
    "$${HOME}/.config/hypr/scripts/commit_hypr.sh"
    "$${HOME}/.config/fish/config.fish"
    "$${HOME}/.config/bash/.bashrc"
  )

  for file in "$${files[@]}"; do
    if [ -f "$$file" ] && [ ! -L "$$file" ]; then
      backup="$$file.backup-$$date"
      echo "Backing up existing file: $$file -> $$backup"
      mv "$$file" "$$backup"
    fi
  done
'';

  xdg.configFile."hypr/hyprland.conf".source = "${inputs.dotfiles}/hypr/hyprland.conf";
  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/toggle_scroll.sh";
    executable = true;
  };

  home.file."/usr/local/bin/commit_hypr.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/toggle_scroll.sh";
    executable = true;
  };

  home.file."/.bashrc" = {
    source = "${inputs.dotfiles}/bash/.bashrc";
    executable = true;
  };


}

