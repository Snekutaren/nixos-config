# machines/qemu/qemu-config.nix
{ config, pkgs, inputs, lib, modulesPath, ... }:
{
  imports = [
    # Hardware profiles
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    # Machine-specific modules
    (inputs.self + "/machines/qemu/qemu-disko.nix")
    (inputs.self + "/machines/qemu/qemu-network.nix")
    (inputs.self + "/machines/qemu/qemu-packages.nix")
    (inputs.self + "/machines/nixrog/qemu-users.nix")

    # Common system modules
    (inputs.self + "/modules/localization.nix")
    (inputs.self + "/modules/sound.nix")
    (inputs.self + "/modules/hypr/hyprland.nix")
  ];

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
    bluetooth.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amdgpu.amdvlk.enable = false;
    graphics = {
      enable = false;
      enable32Bit = true;
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
    };
    dbus.enable = true;
    upower.enable = true;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  disko.enableConfig = true;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";

}
