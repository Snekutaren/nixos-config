#nixos-config/machines/nixqemu/qemu-users.nix
{ config, inputs, lib, pkgs, ... }:
{
  users.users.qemu = {
    isNormalUser = true;
    home = "/home/qemu";
    description = "qemu user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    shell = pkgs.bashInteractive;
    hashedPasswordFile = config.age.secrets.nixqemu-qemu.path;
  };
  users.users.qemu.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8TQIzWbCakGBQGyJTW8WF3Z76NiVc5FiL4mX7dtmoM nixqemu-key"
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; };
    users.qemu.imports = [ (inputs.self + "/machines/nixqemu/users/qemu.nix") ];
  };
  age = {
    identityPaths = [ 
      "/home/qemu/.config/age/age.key" 
      #"/mnt/tmp/age.key" # for first install
    ];
    secrets.nixqemu-qemu = {
      file = "${inputs.self}/secrets/nixqemu-qemu.age";
    };
  };
}