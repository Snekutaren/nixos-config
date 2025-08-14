#!/usr/bin/env bash
set -euo pipefail
#set -x
echo "Checking keys.."
for key in age.key luks.key nix-cache.key; do
  if [ ! -f "/tmp/$key" ]; then
    echo "Place /tmp/$key"
    exit 1
  fi
done

USER=qemu
USER_UID=1000
USER_GID=100
KEY_HOME="/home/$USER/.ssh"
SSH_CONFIG_FILE="$KEY_HOME/config"

export NIX_CONF_DIR=/tmp/nix-conf
mkdir -p "$NIX_CONF_DIR"

cat <<EOF > "$NIX_CONF_DIR/nix.conf"
#post-build-hook = /mnt/etc/nix/upload-to-cache.sh
builders-use-substitutes = true
substituters = http:/local.nix-cache:5000?priority=1 https://cache.nixos.org?priority=10
trusted-public-keys = truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
download-buffer-size = 104857600  # 100 MB
experimental-features = nix-command flakes
require-sigs = false
EOF

sudo systemctl restart nix-daemon
mkdir -p ~/.ssh/nixqemu

cd /tmp/nixos-config
# TODO: age will decrypt LUKS key
sudo --preserve-env=NIX_CONF_DIR \
  nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/nixqemu/nixqemu-disko.nix
#sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS

sudo mkdir -p /mnt/etc/age
sudo cp /tmp/age.key /mnt/etc/age/age.key
sudo chown root:root /mnt/etc/age/age.key
sudo chmod 600 /mnt/etc/age/age.key

# --- Setup SSH config for nix-cache ---
echo "Creating SSH config for nix-cache on liveos..."
sudo mkdir -p /home/nixos/.ssh/
sudo tee /home/nixos/.ssh/config > /dev/null <<EOF
Host local.nix-cache
    HostName local.nix-cache
    User nix-cache
    Port 6622
    IdentityFile /home/nixos/.ssh/nix-cache/nix-cache.key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
sudo chown "1000:100" /home/nixos/.ssh/config
sudo chmod 600 /home/nixos/.ssh/config
if [ ! -f "/home/nixos/.ssh/config" ]; then
    echo "/home/nixos/.ssh/config doesn't exist"
    exit 1
  fi
echo "SSH config created at /home/nixos/.ssh/config"

echo "Creating SSH config for nix-cache on nixqemu..."
sudo mkdir -p /home/qemu/.ssh
sudo tee /home/qemu/.ssh/config > /dev/null <<EOF
Host nix-cache-qemu
    HostName local.nix-cache
    User nix-cache
    Port 6622
    IdentityFile /home/$USER/.ssh/nix-cache/nix-cache.key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
sudo chown "1000:100" "$SSH_CONFIG_FILE"
sudo chmod 600 "$SSH_CONFIG_FILE"
if [ ! -f "$SSH_CONFIG_FILE" ]; then
    echo "SSH config created at $SSH_CONFIG_FILE doesn't exist"
    exit 1
  fi
echo "SSH config created at $SSH_CONFIG_FILE"

export NIX_CONF_DIR=/tmp/nix-conf
sudo --preserve-env=NIX_CONF_DIR \
  nixos-install --root /mnt --no-root-password --flake /tmp/nixos-config#nixqemu

# if /mnt mounted
if mountpoint -q /mnt; then
  mkdir -p /mnt/home/qemu/.ssh && cp /home/qemu/.ssh/config /mnt/home/qemu/.ssh/config
fi

# --- Copy age.key to correct location ---
echo "Copying age.key to /home/$USER/.config/age/age.key .."
sudo mkdir -p "/home/$USER/.config/age"
sudo cp /tmp/age.key "/home/$USER/.config/age/age.key"
sudo chown root:root /home/$USER/.config/age/age.key
sudo chmod -R 600 "/home/$USER/.config/age/age.key"
if mountpoint -q /mnt; then
  mkdir -p /mnt/home/qemu/.config/age && sudo cp /home/qemu/.config/age/age.key /mnt/home/qemu/.config/age/age.key
fi

echo "Copying nix-cache.key to /home/$USER/.ssh/nix-cache/nix-cache.key .."
sudo mkdir -p "/home/$USER/.ssh/nix-cache"
sudo cp /tmp/nix-cache.key "/home/$USER/.ssh/nix-cache/nix-cache.key"
sudo chown 1000:100 /home/$USER/.ssh/nix-cache/nix-cache.key
sudo chmod -R 600 "/home/$USER/.ssh/nix-cache/nix-cache.key"
if mountpoint -q /mnt; then
  mkdir -p /mnt/home/$USER/.ssh/nix-cache && cp /home/$USER/.ssh/nix-cache/nix-cache.key /mnt/home/$USER/.ssh/nix-cache/nix-cache.key
fi

echo "Copying nix-cache.key to /home/nixos/.ssh/nix-cache/nix-cache.key .."
sudo mkdir -p "/home/nixos/.ssh/nix-cache"
sudo cp /tmp/nix-cache.key "/home/nixos/.ssh/nix-cache/nix-cache.key"
sudo chown 1000:100 /home/nixos/.ssh/nix-cache/nix-cache.key
sudo chmod -R 600 "/home/nixos/.ssh/nix-cache/nix-cache.key"

sudo cp -R /tmp/nixos-config /mnt/home/$USER/
echo "Changing ownership from root to nixos/qemu"
sudo chown -R 1000:100 /mnt/home/$USER


echo "Setup complete."
#echo "Pushing build to local cache.."
#nix copy --experimental-features "nix-command" --to ssh://nix-cache-liveos --all
#echo "build pushed to local cache"

sudo mkdir -p /root/.ssh/ && sudo cp -v "$SSH_CONFIG_FILE" /root/.ssh/config
nix copy --to ssh://local.nix-cache \
   /run/current-system \
   --all
