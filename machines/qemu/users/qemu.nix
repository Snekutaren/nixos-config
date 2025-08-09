{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "25.05";
  home.homeDirectory = "/home/qemu";
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    vscode
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # If you use zsh or another shell, you need to enable it here
    # Example for zsh:
    # enableZshIntegration = true;
  };

  programs.bash = {
    enable = true;

    shellAliases = {
      ll = "ls -lah";
      lR = "ls -laR";
      lRl = "ls -laR | less";
    };

    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"

      function reload-conf() {
        echo "Bash configuration reloaded."
        hyprctl reload
        echo "Hyprland configuration reloaded."
      }
    '';
  };

  programs.git = {
    enable = true;
  };

  programs.zsh.enable = false;
  programs.gh.enable = false;
  programs.eww.enable = false;

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
}
