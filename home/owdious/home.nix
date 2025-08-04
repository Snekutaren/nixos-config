# home/owdious/home.nix
{ config, pkgs, home-manager, inputs, lib,... }:
{
  home.stateVersion = "25.05"; # Matching the home-manager release branch
  home.sessionVariables.EDITOR = "nvim";
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    #gamescope
    #brave
    #discord
    #heroic
    #steam
    #vscode
    #vlc
    #playerctl # Media player control
    #thunderbird
    #gimp
    #libreoffice
    #blender
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

    shellAliases = {
      ll = "ls -lah";
      lR = "ls -laR";
      lRl = "ls -laR | less";
      comfyui = "nix develop ~/comfyui/nix";
    };

    initExtra = ''
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
      function build-nix-dry() {
        sudo nixos-rebuild dry-activate --flake ~/nixos-config -v
      }
      function push-build-nix() {
        ssha
        git-push-dot
        update-flake
        build-nix
        git-push-nixos
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
    source = "./hypr/hyprland.conf";
  };

  xdg.configFile."hypr/hyprpaper.conf" = {
    source = "./hypr/hyprpaper.conf";
  };

  xdg.configFile."hypr/hypridle.conf" = {
    source = "./hypr/hypridle.conf";
  };
  
   home.file.".config/hypr/scripts/lock-and-dpms.sh" = {
    source = "./hypr/scripts/lock-and-dpms.sh";
    executable = true;
  };
  
  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
    source = "./hypr/scripts/toggle_scroll.sh";
    executable = true;
  };

  home.file.".config/hypr/scripts/random-hyprpaper.sh" = {
    source = "./hypr/scripts/random-hyprpaper.sh";
    executable = true;
  };

  home.file.".config/hypr/scripts/toggle_monitor_layout.sh" = {
    source = "./hypr/scripts/toggle_monitor_layout.sh";
    executable = true;
  };

  #home.file."/.bashrc" = {
  #  source = "./bash/.bashrc";
  #  executable = true;
  #};

}