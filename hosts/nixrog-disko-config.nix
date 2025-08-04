# disko-config.nix
{ disks ? [ "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b459ecf04" ], lib, ... }: {
  disko.devices = {
    disk.main = {
      device = lib.mkDefault (builtins.elemAt disks 0);
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-n NIXOS_BOOT" ]; # Label for EFI partition
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              extraOpenArgs = [ "--type luks2" ]; # Use LUKS2
              settings = {
                keyFile = "/tmp/luks-keyfile"; # Temporary keyfile for fresh install
                allowDiscards = true; # Enable TRIM for NVMe
                #label = "NIXOS_LUKS"; # Label for LUKS partition
              };
              content = {
                type = "lvm_pv";
                vg = "vg0";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      vg0 = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [ "-L NIXOS_ROOT" ]; # Label for ext4 filesystem
            };
          };
        };
      };
    };
  };
}