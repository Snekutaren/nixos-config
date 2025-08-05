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
  users.users.tellus = {
    isNormalUser = true;
    home = "/home/tellus";
    description = "tellus user";
    extraGroups = [ "wheel" "networkmanager" "audio" "gamemode" "render" "video" ];
    shell = pkgs.bashInteractive;
    #hashedPassword = "$6$mKObq3ioVxnsLIAT$NFRKW3GM5vJxces3XzuwoEWcc2rMAZbjjIBls7nbCh2rgKtDDHVDzsyWQ6Y6MF0O9KtZCbpP15jNBxyI95FWS0";
    hashedPasswordFile = config.age.secrets."users.tellus.hashedPasswordFile".path;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; }; # necessary? just have it called nixpks - and import it with imputs here?
    users.owdious.imports = [ (inputs.self + "/machines/nixrog/users/owdious.nix") ];
    };
}