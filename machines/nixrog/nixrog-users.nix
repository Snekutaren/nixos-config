{ config, lib, pkgs, ... }:

{
  users.users.owdious = {
    isNormalUser = true;
    home = "/home/owdious";
    description = "Owdious user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    # Optional: use agenix for secure password
    # hashedPasswordFile = config.age.secrets.owdious.path;
    shell = pkgs.bashInteractive;
  };
  home-manager.users.owdious = import ./users/owdious.nix;
}