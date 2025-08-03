# home/owdious/home.nix
{ config, pkgs, home-manager, inputs, lib,... }:
{
  home.stateVersion = "25.05"; # Matching the home-manager release branch
  home.sessionVariables.EDITOR = "nvim";
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    gamescope
    brave
    discord
    heroic
    steam
    vscode
    vlc
    playerctl # Media player control
    thunderbird
    gimp
    libreoffice
    blender
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # If you use zsh or another shell, you need to enable it here
    # Example for zsh:
    # enableZshIntegration = true;
  };
  # For the shell to hook into direnv, you need to enable it as a program.
  # This is often already present, but it's good to ensure it's there.
  programs.bash = {
  enable = true;

    # Define aliases
    shellAliases = {
      alias ll = "ls -lah";
      alias lR = "ls -laR";
      alias lRl = "ls -laR | less";
      alias ssha = "eval "$(ssh-agent -s)" && ssh-add ~/.ssh/github/github_ed25519";
      alias git-push-nixos="git -C ~/nixos-config checkout auto && git -C ~/nixos-config add . && (git -C ~/nixos-config commit -m "$(date)" || true) && git -C ~/nixos-config push";
      alias git-push-dot="git -C ~/dotfiles checkout auto && git -C ~/dotfiles add . && (git -C ~/dotfiles commit -m "$(date)" || true) && git -C ~/dotfiles push";
      alias git-push-comfyui="git -C ~/comfyui checkout auto && git -C ~/comfyui add . && (git -C ~/comfyui commit -m "$(date)" || true) && git -C ~/comfyui push";
      alias update-flake="sudo nix flake update --flake ~/nixos-config -v";
      alias build-nix="sudo nixos-rebuild switch --flake ~/nixos-config -v";
      alias push-build-nix="update-flake && git-push-nixos && git-push-dot && build-nix";
      alias comfyui="nix develop ~/comfyui/nix";
      alias reload-conf="source ~/.bashrc && echo "Bash configuration reloaded." && hyprctl reload && echo "Hyprland configuration reloaded."";
    };

    # Use extraInit for environment variables and functions
    extraInit = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # Enable a shell (e.g., Zsh)
  programs.zsh = {
    enable = true;
    # Temporarily removed ohMyZsh to debug "option does not exist" error.
    # It will be re-added or corrected once the base Zsh setup works.
    # ohMyZsh.enable = true; # Example: Enabling Oh My Zsh  <-- THIS LINE MUST BE COMMENTED/REMOVED
  };

  #
  programs.gh.enable = true;

  # Enable Git configuration
  programs.git = {
    enable = true;
    userName = "Snekutaren";
    userEmail = "snekutaren@gmail.com";
  };

  programs.eww = {
    enable = true;
  };
  
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

  xdg.configFile."hypr/hyprland.conf" = {
    source = "${inputs.dotfiles}/hypr/hyprland.conf";
  };

  xdg.configFile."hypr/hyprpaper.conf" = {
    source = "${inputs.dotfiles}/hypr/hyprpaper.conf";
  };

  xdg.configFile."hypr/hypridle.conf" = {
    source = "${inputs.dotfiles}/hypr/hypridle.conf";
  };
  
   home.file.".config/hypr/scripts/lock-and-dpms.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/lock-and-dpms.sh";
    executable = true;
  };
  
  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/toggle_scroll.sh";
    executable = true;
  };

  home.file.".config/hypr/scripts/random-hyprpaper.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/random-hyprpaper.sh";
    executable = true;
  };

  home.file.".config/hypr/scripts/toggle_monitor_layout.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/toggle_monitor_layout.sh";
    executable = true;
  };

  home.file."/.bashrc" = {
    source = "${inputs.dotfiles}/bash/.bashrc";
    executable = true;
  };

}