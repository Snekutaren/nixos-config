{ config, inputs, lib, pkgs, ... }:
{
  users.users.owdious = {
    isNormalUser = true;
    home = "/home/owdious";
    description = "owdious user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    shell = pkgs.bashInteractive;
    hashedPasswordFile = config.age.secrets.nixrog-owdious.path;
  };
  users.users.tellus = {
    isNormalUser = true;
    home = "/home/tellus";
    description = "tellus user";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bashInteractive;
    hashedPasswordFile = config.age.secrets.nixrog-tellus.path;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; };
    users.owdious.imports = [ (inputs.self + "/machines/nixrog/users/owdious.nix") ];
  };
  age = {
    identityPaths = [ "/home/owdious/.config/age/age.key" ];
    secrets.nixrog-tellus = {
      file = "${inputs.self}/secrets/nixrog-tellus.age";
    };
    secrets.nixrog-owdious = {
      file = "${inputs.self}/secrets/nixrog-owdious.age";
    };
  };
}