{ config, pkgs, inputs, lib, ... }:
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
    playerctl
    thunderbird
    gimp
    libreoffice
    blender
    moonlight-qt
    steam-run
    pkgs.tabby
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = false;
  };
  programs.bash = {
    enable = true;
    #initExtra = builtins.readFile (inputs.self + "/modules/bashrc.extra.sh");
  };
  #programs.bash-language-server.enable = true;
  programs.zsh = {
    enable = true;
    #ohMyZsh.enable = false;
  };
  programs.neovim = {
    enable = true;
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
  # Kvantum theme config for Qt
  #xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
  #  [General]
  #  theme=Catppuccin-Mocha
  #'';
  # GTK theme config
  #gtk = {
  #  enable = true;
  #  theme = {
  #    name = "Catppuccin-Mocha-Standard-Lavender-Dark";
  #    package = pkgs.catppuccin-gtk;
  #  };
  #  iconTheme = {
  #    name = "Papirus-Dark";
  #    package = pkgs.papirus-icon-theme;
  #  };
  #  cursorTheme = {
  #    name = "Catppuccin-Mocha-Dark-Cursors";
  #    package = pkgs.catppuccin-cursors;
  #    size = 24;
  #  };
  #};
  # Ensure Qt uses Kvantum
  #qt = {
  #  enable = true;
  #  platformTheme.name = "qtct";
  #  style.name = "kvantum";
  #};
    home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };
}
