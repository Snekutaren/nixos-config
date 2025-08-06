{ config, pkgs, lib, inputs, home-manager, ... }:
{
  home.stateVersion = "25.05"; # Matching the home-manager release branch
  home.homeDirectory = "/home/owdious";
  home.sessionVariables.EDITOR = "nvim";

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
    moonlight-qt
    steam-run
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # If you use zsh or another shell, enable the integration here
    # Example for zsh:
    # enableZshIntegration = true;
  };

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
      export HOME=
      function ssha() {
        pidof ssh-agent || eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/github/github_ed25519
      }

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
      
      function update-flake() {
        sudo nix flake update --flake ~/nixos-config -v
      }

      function build-nix() {
        declare -f build-nix
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

      function reload-conf() {
        echo "Bash configuration reloaded."
        hyprctl reload
        echo "Hyprland configuration reloaded."
      }
    '';
  };
  programs.zsh = {
    enable = true;
    # ohMyZsh.enable = true; # Temporarily disabled to debug errors
  };
  programs.gh.enable = true;
  programs.git = {
    enable = true;
    userName = "Snekutaren";
    userEmail = "snekutaren@gmail.com";
  };
  programs.eww = {
    enable = true;
  };
  xdg.configFile."hypr/hyprland.conf" = {
    source = inputs.self + "/modules/hypr/hyprland.conf";
  };
  xdg.configFile."hypr/hyprpaper.conf" = {
    source = inputs.self + "/modules/hypr/hyprpaper.conf";
  };
  xdg.configFile."hypr/hypridle.conf" = {
    source = inputs.self + "/modules/hypr/hypridle.conf";
  };
  home.file.".config/hypr/scripts/lock-and-dpms.sh" = {
    source = inputs.self + "/modules/hypr/scripts/lock-and-dpms.sh";
    executable = true;
  };
  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
    source = inputs.self + "/modules/hypr/scripts/toggle_scroll.sh";
    executable = true;
  };
  home.file.".config/hypr/scripts/random-hyprpaper.sh" = {
    source = inputs.self + "/modules/hypr/scripts/random-hyprpaper.sh";
    executable = true;
  };
  home.file.".config/hypr/scripts/toggle_monitor_layout.sh" = {
    source = inputs.self + "/modules/hypr/scripts/toggle_monitor_layout.sh";
    executable = true;
  };
  # Uncomment and adjust if you want to manage .bashrc via home-manager
  # home.file."/.bashrc" = {
  #   source = ./bash/.bashrc;
  #   executable = true;
  # };
}
