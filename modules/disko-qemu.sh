#!/bin/bash
set -euo pipefail

USER=qemu
KEY_HOME="/home/$USER/.config/age/"

# 1. Manually set up the temporary nix.conf file.
export NIX_CONF_DIR=/tmp/nix-conf
mkdir -p $NIX_CONF_DIR
cat <<EOF > $NIX_CONF_DIR/nix.conf
substituters = http://10.0.20.100:5000?priority=1 https://cache.nixos.org?priority=10
trusted-public-keys = truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
experimental-features = nix-command flakes
EOF
sudo systemctl restart nix-daemon

if [ -d "/tmp/nixos-config" ]; then
  sudo rm -rf /tmp/nixos-config
fi
mkdir -p "/tmp/nixos-config"
git clone -b auto https://github.com/snekutaren/nixos-config.git /tmp/nixos-config

sudo -E nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/nixqemu/nixqemu-disko.nix

#sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS

sudo mkdir -p /mnt/etc/age
if [ -f "/tmp/age.key" ]; then
  sudo cp "/tmp/age.key" "/mnt/etc/age/age.key"
  sudo chown root:root "/mnt/etc/age/age.key"
  sudo chmod 600 "/mnt/etc/age/age.key"
else
  echo "/tmp/age.key not found!"
fi

sudo -E nixos-install --root "/mnt" --flake "/tmp/nixos-config#nixqemu" -v

echo "Copying age.key to $KEY_HOME .."
sudo mkdir -p "$KEY_HOME"
if [ -f "/tmp/age.key" ]; then
  sudo cp "/tmp/age.key" "$KEY_HOME/age.key"
  sudo chown "root" "$KEY_HOME/age.key"
  sudo chmod 600 "$KEY_HOME/age.key"
else
  echo "/tmp/age.key not found!"
fi
sudo ls -la "$KEY_HOME"
