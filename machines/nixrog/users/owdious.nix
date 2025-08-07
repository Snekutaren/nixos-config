{ config, pkgs, inputs, lib, home-manager, ... }:
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
    #steam-run
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
    initExtra = builtins.readFile (inputs.self + "/modules/bashrc.extra.sh");
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
  xdg.configFile = {
    "hypr/hyprland.conf".source = inputs.self + "/modules/hypr/hyprland.conf";
    "hypr/hyprpaper.conf".source = inputs.self + "/modules/hypr/hyprpaper.conf";
    "hypr/hypridle.conf".source = inputs.self + "/modules/hypr/hypridle.conf";
  };
  home.file = {
    ".config/hypr/scripts/lock-and-dpms.sh" = {
      source = inputs.self + "/modules/hypr/scripts/lock-and-dpms.sh";
      executable = true;
    };
    ".config/hypr/scripts/toggle_scroll.sh" = {
      source = inputs.self + "/modules/hypr/scripts/toggle_scroll.sh";
      executable = true;
    };
    ".config/hypr/scripts/random-hyprpaper.sh" = {
      source = inputs.self + "/modules/hypr/scripts/random-hyprpaper.sh";
      executable = true;
    };
    ".config/hypr/scripts/toggle_monitor_layout.sh" = {
      source = inputs.self + "/modules/hypr/scripts/toggle_monitor_layout.sh";
      executable = true;
    };
  };
  # home.file."/.bashrc" = {
  #   source = ./bash/.bashrc;
  #   executable = true;
  # };
}
