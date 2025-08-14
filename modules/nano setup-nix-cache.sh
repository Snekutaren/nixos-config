#!/usr/bin/env bash
set -euo pipefail

# This script automates the setup of a dedicated 'nix-cache' user account
# for a remote Nix store with enhanced security. It uses the /bin/sh shell
# to allow for non-interactive command execution via SSH, fixing the
# 'nologin' protocol mismatch error.

# --- Configuration Variables ---
CACHE_USER="nix-cache"
CACHE_HOME="/home/$CACHE_USER"
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpm7uJcX9EsBDoiExTxCsB23s26CJv3A6EK43aIk8ce nix-cache@x570-machine"

echo "=> [1/4] Creating restricted nix-cache user..."
# Remove the existing user to ensure a clean setup.
if id "$CACHE_USER" &>/dev/null; then
    echo "    -> User $CACHE_USER already exists, deleting user and home directory..."
    sudo userdel -r "$CACHE_USER" || true
fi
# Create the user with a home directory and a non-interactive shell for security.
echo "    -> Recreating '$CACHE_USER' with /bin/sh shell."
sudo useradd -m -s /bin/sh "$CACHE_USER"

SSH_DIR="$CACHE_HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo "=> [2/4] Setting up SSH directory and authorized_keys..."
# Create and secure the .ssh directory and authorized_keys file.
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"
sudo touch "$AUTH_KEYS"
sudo chmod 600 "$AUTH_KEYS"
sudo chown -R "$CACHE_USER:$CACHE_USER" "$SSH_DIR"

echo "=> [3/4] Adding public key and user to the correct groups..."
# Add the user to the groups required for Nix daemon communication.
sudo usermod -aG nix-users,nixbld "$CACHE_USER"
echo "    -> User '$CACHE_USER' added to 'nix-users' and 'nixbld' groups."

# Add the public key to the authorized_keys file.
echo "$PUBKEY" | sudo tee "$AUTH_KEYS" >/dev/null
echo "    -> Public key added for passwordless access."

echo "=> [4/4] Restarting SSH..."
# Restart the SSH service to apply the changes.
sudo systemctl restart sshd

echo "Done!"
echo "You can now push builds from your build machine like this:"
echo "  nix copy --to ssh://$CACHE_USER@server /nix/store/<path>"
