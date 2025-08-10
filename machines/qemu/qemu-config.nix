# machines/qemu/qemu-config.nix
{ config, pkgs, inputs, lib, modulesPath, attic, ... }:
{
  imports = [
    # Hardware profiles
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    # Machine-specific modules
    (inputs.self + "/machines/qemu/qemu-disko.nix")
    (inputs.self + "/machines/qemu/qemu-network.nix")
    (inputs.self + "/machines/qemu/qemu-packages.nix")
    #(inputs.self + "/machines/nixrog/nixrog-packages.nix")
    (inputs.self + "/machines/qemu/qemu-users.nix")
    # Common system modules
    (inputs.self + "/modules/localization.nix")
    (inputs.self + "/modules/sound.nix")
  ];
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "http://10.0.20.100:5000/default"
        #"https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "default:bA7oAEsF4sbVd1KDEINX7ZC9WUtp14lS66ucSnfC1fo="
        #"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [ "root" "qemu" ];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "uhci_hcd" "ehci_pci" "virtio_pci" "virtio_blk" ];
      kernelModules = [ "dm-snapshot" "cryptd" "cifs" ];
      luks.devices.cryptroot = {
        device = lib.mkForce "/dev/disk/by-label/NIXOS_LUKS";
        preLVM = true;
        allowDiscards = true;
        # keyFile = "/etc/luks-keys/cryptroot.key";
      };
    };
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  disko.enableConfig = true;
  fileSystems."/" = {
    device = lib.mkForce "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = lib.mkForce "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };
  services = {
    xserver = {
      enable = true;
      videoDrivers = [
        "modesetting"  # Generic driver for modern virtual GPUs (e.g. virtio-vga)
        "qxl"          # For QEMU QXL/SPICE display adapter
        "vesa"         # Fallback driver for generic VGA
        "fbdev"        # Framebuffer device fallback
        "cirrus"       # Legacy QEMU adapter (deprecated, but included for completeness)
        "vmware"       # For VM environments using vmware adapter
        "ast"          # ASPEED virtual graphics (used in some server VMs)
      ];
      xrandrHeads = [ "Virtual-1" ];

      displayManager.sessionCommands = ''
        xrandr --output Virtual-1 --mode 1920x1080
      '';
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  dbus.enable = true;
    openssh = {
        enable = true;
        ports = [ 6622 ];
    };

  #attic.autoPush = {
  #  enable = true;
  #  # Replace 'default' with your cache name if it's different
  #  cache = "default";
  #};

  #displayManager.gdm.enable = true;
  #desktopManager.gnome.enable = true;

  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
}