#!/usr/bin/env bash
set -euo pipefail
set -x #debug

USER=qemu
USER_UID=1000
USER_GID=100
export NIX_CONF_DIR=/tmp/nix-conf
export AGE_KEY=/tmp/age.key

mkdir -p "$NIX_CONF_DIR"
cat <<EOF > "$NIX_CONF_DIR/nix.conf"
#post-build-hook = /mnt/etc/nix/upload-to-cache.sh
#builders-use-substitutes = true
substituters = http:/local.nix-cache:5000?priority=1 https://cache.nixos.org?priority=10
trusted-public-keys = truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
download-buffer-size = 209715200  # 200 MB
experimental-features = nix-command flakes
require-sigs = false
EOF
sudo systemctl restart nix-daemon
echo "Testing local cache..."
nix store info --store http://local.nix-cache:5000 || echo "Warning: Local cache unreachable"

echo "Preparing keys..."
for key in age.key nixqemu-luks.key local.nix-cache.key; do
  if [ ! -f "/tmp/$key" ]; then
    echo "Place /tmp/$key"
    exit 1
  else
    sudo chown -v root:root "/tmp/$key"
    sudo chmod -Rv 600 "/tmp/$key"
  fi
done
# --- Setup SSH config for nix-cache ---
echo "Creating SSH config for nix-cache on liveos..."
sudo mkdir -p /home/nixos/.ssh/
sudo tee /home/nixos/.ssh/config > /dev/null <<EOF
Host local.nix-cache
    HostName local.nix-cache
    User nix-cache
    Port 6622
    IdentityFile /home/nixos/.ssh/local.nix-cache.key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
sudo chown "1000:100" /home/nixos/.ssh/config
sudo chmod 600 /home/nixos/.ssh/config
if [ ! -f "/home/nixos/.ssh/config" ]; then
    echo "/home/nixos/.ssh/config doesn't exist"
    exit 1
  fi

# TODO: age will decrypt LUKS key
# TODO: add a second key - sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS
echo "Setting up filesystem..."
sudo --preserve-env=NIX_CONF_DIR \
  nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/nixqemu/nixqemu-disko.nix

echo "Copying age.key to user config..."
if mountpoint -q /mnt; then
  sudo mkdir -p /mnt/home/"$USER"/.config/age && sudo cp -v /tmp/age.key /mnt/home/"$USER"/.config/age/age.key
fi
echo "Copying local.nix-cache.key..."
sudo cp -v /tmp/local.nix-cache.key /home/nixos/.ssh/local.nix-cache.key
if mountpoint -q /mnt; then
  sudo mkdir -p /mnt/home/$USER/.ssh/ && sudo cp -v /tmp/local.nix-cache.key /mnt/home/$USER/.ssh/local.nix-cache.key
fi

echo "Installing system..."
#                                                                                                 export NIX_CONF_DIR=/tmp/nix-conf
sudo --preserve-env=NIX_CONF_DIR \
  nixos-install --root /mnt --no-root-password --flake /tmp/nixos-config#nixqemu

echo "Copying nixos-config to installation dir..."
sudo cp -R /tmp/nixos-config /mnt/home/"$USER"/
echo "Changing ownership to "$USER_UID":"$USER_GID"..."
sudo chown -R "$USER_UID":"$USER_GID" /mnt/home/"$USER"

echo "Setup complete."
echo "Pushing build to local cache.."
sudo mkdir -p /root/.ssh/ && sudo cp -v /home/nixos/.ssh/config /root/.ssh/config
sudo --preserve-env=NIX_CONF_DIR \
  NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" \
  #nix copy --to ssh://local.nix-cache $(nix-store -qR --include-outputs $(nix-env -q --out-path))
  #ix copy --to ssh://local.nix-cache $(find /nix/store -maxdepth 1 -type d)
  #nix copy --to ssh://local.nix-cache --all -v
echo "Build cached..."
