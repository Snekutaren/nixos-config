# hosts/nixrog/users.nix
# User definitions specific to the 'rog' machine.

{ config, pkgs, ... }:

{
  users.users.owdious = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio"]; # 'networkmanager' for GUI network control
    password = "password"; # WARNING: Use a hash or set post-install in production!
                           # For production, consider using 'mkpasswd -m sha512' to generate a hash.
  };

  # Add any other users specific to this 'nixrog' machine here.
  # users.users.guestuser = {
  #   isNormalUser = true;
  #   extraGroups = [ "users" ];
  #   password = "guestpassword";
  # };
}
