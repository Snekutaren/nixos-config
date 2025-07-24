# home/owdious/home.nix
{ config, pkgs, inputs, ... }:

{
  # Restore home-manager state
  home.stateVersion = "25.05"; # Matching the home-manager release branch

  # Set default editor
  home.sessionVariables.EDITOR = "nvim";

  # Home Manager needs to know your user's home directory
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    #firefox # Example: Installation of Firefox for the user
    #neovim  # Example: Installation of Neovim
    brave
    git
    discord
    heroic
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

#  # This declares a symlink for your hyprland.conf file
#  xdg.configFile."hypr/hyprland.conf" = {
#    # The source now points to the file in your new location
#    source = "${config.home.homeDirectory}/git/dotfiles/hypr/hyprland.conf";
#  };

#  # This declares a symlink for your toggle_scroll.sh script
#  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
#    # The source now points to the script in your new location
#    source = "${config.home.homeDirectory}/git/dotfiles/hypr/scripts/toggle_scroll.sh";
#    executable = true;
#  };

  xdg.configFile."hypr/hyprland.conf".source = "${inputs.dotfiles}/hypr/hyprland.conf";
  home.file.".config/hypr/scripts/toggle_scroll.sh" = {
    source = "${inputs.dotfiles}/hypr/scripts/toggle_scroll.sh";
    executable = true;
  };

#  home.file."/.bashrc" = {
#    source = "${inputs.dotfiles}/bash/bashrc";
#    executable = true;
#  };


}

