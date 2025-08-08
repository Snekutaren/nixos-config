#!/bin/bash
mkdir -p  /tmp/nixos-config
git clone -b auto https://github.com/snekutaren/nixos-config.git /tmp/nixos-config
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/qemu/qemu-disko.nix
#sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS
sudo mkdir -p /mnt/etc/age
sudo cp /tmp/age.key /mnt/etc/age/age.key
sudo chown root:root /mnt/etc/age/age.key
sudo chmod 600 /mnt/etc/age/age.key
sudo nixos-install --root /mnt --flake /tmp/nixos-config#qemu -v