#!bin/bash
mkdir -p  /tmp/nixos-config
git clone -b auto https://github.com/snekutaren/nixos-config.git /tmp/nixos-config
#sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/nixos-config/hosts/qemu-disko.nix
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/qemu/qemu-disko.nix
#sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS
#sudo nixos-generate-config --no-filesystems --root /mnt
sudo nixos-install --root /mnt --flake /tmp/nixos-config#qemu -v