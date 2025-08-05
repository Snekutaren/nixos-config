# machines/nixrog/nixrog-config.nix
{ config, pkgs, inputs, lib, modulesPath, ... }:

{
  imports = [
    # Hardware profiles
    (modulesPath + "/installer/scan/not-detected.nix")
    # Machine-specific modules
    (inputs.self + "/machines/nixrog/nixrog-disko.nix")
    (inputs.self + "/machines/nixrog/nixrog-network.nix")
    (inputs.self + "/machines/nixrog/nixrog-packages.nix")
    (inputs.self + "/machines/nixrog/nixrog-users.nix")
    # Common system modules
    (inputs.self + "/modules/localization.nix")
    (inputs.self + "/modules/sound.nix")
    #(inputs.self + "/modules/backup.nix")
    (inputs.self + "/modules/hypr/hyprland.nix")
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-sandbox-paths = [ "/dev/kfd" "/dev/dri/renderD128" ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "cryptd" "cifs" ];
      luks.devices.cryptroot = {
        device = lib.mkForce "/dev/disk/by-label/NIXOS_LUKS";
        preLVM = true; # Ensure LUKS is opened before LVM
        allowDiscards = true;
        # keyFile = "/etc/luks-keys/cryptroot.key";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  disko.enableConfig = true;

  fileSystems = {
    "/" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_ROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  hardware = {
    bluetooth.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    xone.enable = true;
    xpad-noone.enable = true;
    amdgpu = {
      amdvlk.enable = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "amdgpu" ];
    };
    dbus.enable = true;
    blueman.enable = true;
    upower.enable = true;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  programs.gamemode.enable = true;
}
