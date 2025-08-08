#!/bin/bash
set -euo pipefail

USER=qemu
KEY_HOME="/home/$USER/.config/age/"

mkdir -p "/tmp/nixos-config"
git clone -b auto https://github.com/snekutaren/nixos-config.git /tmp/nixos-config

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/qemu/qemu-disko.nix

#sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS

sudo mkdir -p /mnt/etc/age
if [ -f "/tmp/age.key" ]; then
  sudo cp "/tmp/age.key" "/mnt/etc/age/age.key"
  sudo chown root:root "/mnt/etc/age/age.key"
  sudo chmod 600 "/mnt/etc/age/age.key"
else
  echo "/tmp/age.key not found!"
fi

sudo nixos-install --root "/mnt" --flake "/tmp/nixos-config#qemu" -v

echo "Copying age.key to $KEY_HOME .."

sudo mkdir -p "$KEY_HOME"
if [ -f "/tmp/age.key" ]; then
  sudo cp "/tmp/age.key" "$KEY_HOME/age.key"
  sudo chown "$USER:users" "$KEY_HOME/age.key"
  sudo chmod 600 "$KEY_HOME/age.key"
else
  echo "/tmp/age.key not found!"
fi

sudo ls -la "$KEY_HOME"
