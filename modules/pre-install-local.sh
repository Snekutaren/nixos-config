#!/usr/bin/env bash
set -euo pipefail

echo "Checking keys.."
for key in age.key luks.key nix-cache.key; do
  if [ ! -f "/tmp/$key" ]; then
    echo "Place /tmp/$key"
    exit 1
  fi
done

USER=qemu
KEY_HOME="/home/$USER/.config/age/"
SSH_DIR="/home/$USER/.ssh"
SSH_CONFIG_FILE="$SSH_DIR/config"

export NIX_CONF_DIR=/tmp/nix-conf
mkdir -p "$NIX_CONF_DIR"
cat <<EOF > "$NIX_CONF_DIR/nix.conf"
substituters = http://10.0.20.100:5000?priority=1 https://cache.nixos.org?priority=10
trusted-public-keys = truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
experimental-features = nix-command flakes
EOF

sudo systemctl restart nix-daemon
mkdir -p ~/.ssh/qemu

cd /tmp/nixos-config
# TODO: age will decrypt LUKS key
sudo -E nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko /tmp/nixos-config/machines/nixqemu/nixqemu-disko.nix
# sudo cryptsetup luksAddKey /dev/disk/by-label/NIXOS_LUKS

sudo mkdir -p /mnt/etc/age
sudo cp /tmp/age.key /mnt/etc/age/age.key
sudo chown root:root /mnt/etc/age/age.key
sudo chmod 600 /mnt/etc/age/age.key

sudo -E nixos-install --root "/mnt" --no-root-password --flake "/tmp/nixos-config#nixqemu" -v

# --- Setup SSH config for nix-cache ---
echo "Creating SSH config for nix-cache..."
sudo mkdir -p "$SSH_DIR"
sudo tee "$SSH_CONFIG_FILE" > /dev/null <<EOF
Host nix-cache
    HostName 10.0.20.100
    User nix-cache
    Port 6622
    IdentityFile $KEY_HOME/nix-cache.key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

sudo chown "$USER:$USER" "$SSH_CONFIG_FILE"
sudo chmod 600 "$SSH_CONFIG_FILE"
echo "SSH config created at $SSH_CONFIG_FILE"

# --- Copy age.key and nix-cache.key to correct locations ---
echo "Copying age.key and nix-cache.key to $KEY_HOME .."
sudo mkdir -p "$KEY_HOME"
sudo cp /tmp/age.key "$KEY_HOME/age.key"
sudo cp /tmp/nix-cache.key "$KEY_HOME/nix-cache.key"
sudo chown root:root "$KEY_HOME/"*.key
sudo chmod 600 "$KEY_HOME/"*.key

sudo ls -la "$KEY_HOME"

echo "Setup complete."
echo "Pushing build to local cache.."
nix copy --to ssh://nix-cache /run/current-system -vvv