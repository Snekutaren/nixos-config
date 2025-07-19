# home/owdious/home.nix
{ config, pkgs, ... }:

{
  # Home Manager needs to know your user's home directory
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    firefox # Example: Install Firefox for your user
    neovim  # Example: Install Neovim
  ];

  # Enable a shell (e.g., Zsh)
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true; # Example: Enable Oh My Zsh

  # Enable Git configuration
  programs.git = {
    enable = true;
    userName = "Owdious";
    userEmail = "owdious@example.com";
  };

  # Set default editor
  home.sessionVariables.EDITOR = "nvim";

  # Restore home-manager state
  home.stateVersion = "23.11"; # Match your home-manager release branch
}