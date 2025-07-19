# hosts/nixrog/nixrog-configuration.nix
# Main configuration file for the 'nixrog' NixOS machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    # ... (all your existing imports) ...
    ./nixrog-hardware-configuration.nix
    ./nixrog-users.nix
    ../../modules/common/common.nix
    ../../modules/common/sound.nix
    ../../modules/common/localization.nix
    ../../modules/common/display-manager.nix
    ../../modules/desktop/plasma.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/deepin.nix
  ];

  # ... (existing host-specific settings) ...
  networking.hostName = "nixrog";
  system.stateVersion = "25.05";

  # === FIX FOR CONFLICTING DEFAULT SESSIONS ===
  # Force Hyprland to be the default session, even if other DEs try to set their own.
  # This assumes 'hyprland' is the session name, which is standard.
  services.displayManager.defaultSession = lib.mkForce "hyprland";

  # ... (rest of your configuration) ...
  services.openssh.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;
  networking.useDHCP = lib.mkForce true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}