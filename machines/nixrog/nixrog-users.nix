{ config, inputs, lib, pkgs, ... }:

{
  users.users.owdious = {
    isNormalUser = true;
    home = "/home/owdious";
    description = "owdious user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    # Optional: use agenix for secure password
    # hashedPasswordFile = config.age.secrets.owdious.path;
    shell = pkgs.bashInteractive;
  };

  users.users.tesser = {
    isNormalUser = true;
    home = "/home/tesser";
    description = "tesser user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    # Optional: use agenix for secure password
    # hashedPasswordFile = config.age.secrets.tesser.path;
    shell = pkgs.bashInteractive;
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; }; # necessary? just have it called nixpks - and import it with imputs here?
    users.owdious.imports = [ (inputs.self + "/machines/nixrog/users/owdious.nix") ];
    };
}