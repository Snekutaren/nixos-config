# home/owdious/home.nix
{ config, pkgs, inputs, lib,... }:
{
  home.stateVersion = "25.05"; # Matching the home-manager release branch
  home.sessionVariables.EDITOR = "nvim";
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    brave
    discord
    heroic
    steam
    vscode
    vlc
    thunderbird
    gimp
    libreoffice
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

  home.file.".config/hypr/hypridle.conf".text = ''
    listener {
        timeout = 300
        on-timeout = pidof hyprlock || bash ~/.config/hypr/scripts/lock-and-dpms.sh
        on-resume = hyprctl dispatch dpms on
        #on-suspend = hyprctl dispatch dpms off
        #on-lock = pidof hyprlock || hyprlock
        #on-unlock = hyprctl dispatch dpms on
    }
    listener {
    }
  '';
  
  home.file.".config/hypr/scripts/lock-and-dpms.sh" = {
    text = ''
      #!/bin/bash
        pidof hyprlock || hyprlock &
        sleep 2
        (
            while pidof hyprlock > /dev/null; do
                sleep 60
                if pidof hyprlock > /dev/null; then
                    DPMS_STATUS=$(hyprctl monitors | grep dpmsStatus | head -n 1 | awk '{print $2}')
                    if [ "$DPMS_STATUS" = "1" ]; then
                        sleep 0.5 && hyprctl dispatch dpms off
                    fi
                else
                    break
                fi
            done
        ) &
    '';
    executable = true;
  };
  
  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/toggle_scroll.sh";
    executable = true;
  };

  home.file."/usr/local/bin/commit_hypr.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/commit_hypr.sh";
    executable = true;
  };

  home.file."/.bashrc" = {
    source = "${inputs.dotfiles}/bash/.bashrc";
    executable = true;
  };

}