# disko-config.nix
# This file defines the disk layout for a NixOS installation.
# It is designed to be used with the `disko` tool from a NixOS Live ISO.
# This version includes an option to use a password from a file for
# automated decryption, which is useful with tools like agenix.
{ config, pkgs, lib, ... }:

let
  # Use the stable by-id path for the physical disk to avoid issues
  # with device names changing between boots (e.g., nvme1n1 vs nvme0n1).
  # We will use the nvme-eui identifier as a best practice.
  # The user's provided nvme-eui path is:
  # lrwxrwxrwx 1 root root  13 Aug  3 22:36 nvme-eui.e8238fa6bf530001001b448b459ecf04 -> ../../nvme1n1
  targetDiskEui = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b459ecf04";

  # The other descriptive device identifier provided by the user.
  targetDiskWds = "/dev/disk/by-id/nvme-WDS100T1XHE-00AFY0_21474A803146";

  # We use a compile-time assertion to ensure both identifiers resolve to the
  # same physical device. If they don't, the Nix build will fail with a clear
  # error message, preventing any accidental data loss.
  targetDisk =
    if lib.readlink targetDiskEui == lib.readlink targetDiskWds then
      targetDiskEui
    else
      throw "Error: The EUI and WDS identifiers point to different devices! Please check your disk layout.";
in
{
  # Ensure the disko module is enabled and will manage our disks.
  disko.enable = true;

  # Define the devices. The structure now follows the correct pattern
  # from the example provided.
  disko.devices = {
    # The 'disk' block defines the physical disk and its partitions.
    disk = {
      # We give a symbolic name to our disk for easy reference.
      main = {
        # The actual device path to be used by disko.
        device = targetDisk;
        # Define the partition table type.
        type = "disk";
        content = {
          # The partition table type is now specified directly as 'gpt'.
          type = "gpt";
          partitions = {
            # Partition 1: The EFI System Partition for /boot.
            NIXOS_BOOT = {
              size = "512M";
              # This has been changed to the correct GPT partition type for EFI.
              type = "EF00";
              content = {
                type = "filesystem";
                # Format as vfat as required for EFI boot.
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            # Partition 2: The encrypted root partition.
            root = {
              size = "100%";
              # This has been changed to a common GPT type for a Linux filesystem.
              type = "8300";
              content = {
                # This content is a LUKS container.
                type = "luks";
                # The label for the LUKS container.
                name = "NIXOS_LUKS";
                # The content of the LUKS container is an LVM physical volume.
                content = {
                  type = "lvm_pv";
                  # This `vg` attribute links this PV to the top-level
                  # `lvm_vg` named "vg0" defined below.
                  vg = "vg0";
                };
                # --- agenix/password file configuration ---
                # To use a password from a file for full automation,
                # uncomment the line below. You would use a file that is
                # decrypted by agenix. This is for non-interactive setups.
                # The path should point to the decrypted secret.
                # passwordFile = "/run/agenix/path-to-your-luks-password-file";
              };
            };
          };
        };
      };
    };

    # The 'lvm_vg' block is a top-level definition, separate from the disk.
    lvm_vg = {
      # The name of the volume group, which must match the `vg` in `lvm_pv`.
      vg0 = {
        type = "lvm_vg";
        # Define the logical volumes that live inside this volume group.
        lvs = {
          # The root logical volume.
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              # The label for the root filesystem.
              label = "NIXOS_ROOT";
              # The mount point for the root partition.
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
