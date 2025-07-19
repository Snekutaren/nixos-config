# home/owdious/home.nix
{ config, pkgs, ... }:

{
  # Home Manager needs to know your user's home directory
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    firefox # Example: Installation of Firefox for the user
    neovim  # Example: Installation of Neovim
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
    userName = "Owdious";
    userEmail = "owdious@example.com";
  };

  # Set default editor
  home.sessionVariables.EDITOR = "nvim";

  # Restore home-manager state
  home.stateVersion = "25.05"; # Matching the home-manager release branch
}