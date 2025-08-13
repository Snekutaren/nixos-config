# /tmp/pre-install-flake/flake.nix
{
  description = "Minimal pre-install flake for cache settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.pre-install = nixpkgs.lib.nixosSystem { # <-- This is the key
      inherit system;
      modules = [
        # This is your configuration module
        {
          nix.settings = {
            substituters = [
              "http://10.0.20.100:5000?priority=1"
              "https://cache.nixos.org?priority=10"
            ];
            trusted-public-keys = [
              "truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8="
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
            experimental-features = [ "nix-command" "flakes" ];
          };
          # Add a state version to make it a valid NixOS config
          system.stateVersion = "25.05";
          # A minimal package to ensure the build completes
          environment.systemPackages = with pkgs; [ git wget ];
          boot = {
            initrd = {
              #availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "uhci_hcd" "ehci_pci" "virtio_pci" "virtio_blk" ];
              #kernelModules = [ "dm-snapshot" "cryptd" "cifs" ];
              luks.devices.cryptroot = {
                device = "/dev/disk/by-label/NIXOS_LUKS";
                preLVM = true;
                allowDiscards = true;
                # keyFile = "/etc/luks-keys/cryptroot.key";
              };
            };
            #kernelModules = [ "kvm-amd" ];
            #kernelPackages = pkgs.linuxPackages_latest;
          };
          boot.loader.grub.enable = false;
          boot.loader.systemd-boot.enable = false;
          boot.loader.generic-extlinux-compatible.enable = false;
          boot.loader.efi.canTouchEfiVariables = false;
          boot.isContainer = true;
          
          #disko.enableConfig = true;
          fileSystems."/" = {
            device =  "/dev/disk/by-label/NIXOS_ROOT";
            fsType = "ext4";
          };
          fileSystems."/boot" = {
            device = "/dev/disk/by-label/NIXOS_BOOT";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
          };
          users.users.root = {
            password = "ostfralla";
          };
        }
      ];
    };
  };
}