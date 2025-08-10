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
      for cmd in nv vi vim nano; do alias $cmd='nvim'; done
      alias ls='eza -a --icons --git --color=always'
      alias ll='eza -lah --icons --git --color=always'
      alias tree='eza --tree --icons --git --color=always'
      alias treel='eza --tree --icons --git --color=always | less'
      alias reload='source ~/.bashrc'
      function reload-conf() {
        echo "Bash configuration reloaded."
        hyprctl reload
        echo "Hyprland configuration reloaded."
      }
      function ssha() {
        pidof ssh-agent || eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/github/github_ed25519
      }
      function check-flake() {
      sudo nix flake check --flake ~/nixos-config -v
      }
      function update-flake() {
          sudo nix flake update ~/nixos-config -v
      }
      function build-attic-push() {
          local SYSTEM_PATH=$(nix build --no-link --print-out-paths ~/nixos-config#nixosConfigurations.nixqemu.config.system.build.toplevel)
          attic push -j 8 default $SYSTEM_PATH
      }      
      function build-nix-dry() {
          local SYSTEM_PATH=$(nix build --no-link --print-out-paths ~/nixos-config#nixosConfigurations.nixqemu.config.system.build.toplevel)
          attic push -j 8 default $SYSTEM_PATH
          sudo nixos-rebuild dry-activate --flake ~/nixos-config -v
      }
      function build-nix-test() {
          local SYSTEM_PATH=$(nix build --no-link --print-out-paths ~/nixos-config#nixosConfigurations.nixqemu.config.system.build.toplevel)
          attic push -j 8 default $SYSTEM_PATH
          sudo nixos-rebuild test --flake ~/nixos-config#nixqemu -v
      }
      function deploy-nix() {
          check-flake && \
          build-attic-push && \
          sudo nixos-rebuild dry-activate --flake ~/nixos-config -v && \
          sudo nixos-rebuild test --flake ~/nixos-config#nixqemu -v && \
          sudo nixos-rebuild switch --flake ~/nixos-config#nixqemu -v
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
