# nixrog-disko-config.nix
{ lib, diskos, inputs, ... }: {
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b459ecf04"; # (nvme-WDS100T1XHE-00AFY0_21474A803146)
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00"; # EFI System Partition
            #label = "NIXOS_BOOT"; # Match existing partition label
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-n NIXOS_BOOT" ]; # Filesystem label
            };
          };
          luks = {
            size = "100%";
            label = "NIXOS_LUKS"; # Match existing partition label
            content = {
              type = "luks";
              name = "cryptroot"; # Maps to /dev/mapper/cryptroot
              extraFormatArgs = [ "--label=NIXOS_LUKS" ]; # Set LUKS label
              settings = {
                #keyFile = "/tmp/luks-keyfile"; # Temporary keyfile for fresh install
                allowDiscards = true; # Enable TRIM for NVMe
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
              extraArgs = [ "-L NIXOS_ROOT" ]; # Filesystem label
            };
          };
        };
      };
    };
  };
}