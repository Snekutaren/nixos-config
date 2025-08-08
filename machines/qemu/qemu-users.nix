#nixos-config/machines/qemu/qemu-users.nix
{ config, inputs, lib, pkgs, ... }:
{
  users.users.qemu = {
    isNormalUser = true;
    home = "/home/qemu";
    description = "qemu user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    shell = pkgs.bashInteractive;
    hashedPasswordFile = config.age.secrets.qemu-qemu.path;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; };
    users.qemu.imports = [ (inputs.self + "/machines/qemu/users/qemu.nix") ];
  };
  age = {
    identityPaths = [ 
      "${config.users.users.qemu.home}/.config/age/age.key" 
      "/etc/age/age.key" # translates to /mnt/etc/age/age.key when installing..
    ];
    secrets.qemu-qemu = {
      file = "${inputs.self}/secrets/qemu-qemu.age";
    };
  };
}