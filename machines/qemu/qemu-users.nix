{ config, inputs, lib, pkgs, ... }:

{
  users.users.qemu = {
    isNormalUser = true;
    home = "/home/qemu";
    description = "qemu user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    hashedPasswordFile = config.age.secrets.qemu-qemu.path;
    shell = pkgs.bashInteractive;
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; }; # necessary? just have it called nixpks - and import it with imputs here?
    users.qemu.imports = [ (inputs.self + "/machines/qemu/users/qemu.nix") ];
    };
  age = {
    identityPaths = [ "/home/qemu/.config/age/age.key" ];
    secrets.nixrog-owdious = {
      file = "${inputs.self}/secrets/qemu-qemu.age";
    };
  };
}