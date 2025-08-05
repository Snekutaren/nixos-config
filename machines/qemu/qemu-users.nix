{ config, lib, pkgs, ... }:

{
  users.users.qemu = {
    isNormalUser = true;
    home = "/home/qemu";
    description = "QEMU user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    # Optional: use agenix for secure password
    # hashedPasswordFile = config.age.secrets.qemu.path;
    shell = pkgs.bashInteractive;
  };
  home-manager.users.qemu = import ./users/qemu.nix;
}
