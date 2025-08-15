#!/usr/bin/env bash
set -euo pipefail

USER=owdious
REMOTE="nixos@nixos"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Append qemu.pub to authorized_keys
ssh $SSH_OPTS "$REMOTE" "mkdir -p /home/nixos/.ssh && cat >> /home/nixos/.ssh/authorized_keys" < /home/"$USER"/.ssh/nixqemu.pub
ssh $SSH_OPTS "$REMOTE" sudo rm -rf /tmp/nixos-config/
# Copy nixos-config directory
rsync -av -e "ssh $SSH_OPTS" \
    /home/"$USER"/nixos-config/ \
    "$REMOTE:/home/nixos/nixos-config/"
# Copy individual key files
rsync -av -e "ssh $SSH_OPTS" \
    /home/"$USER"/.keys/age.key \
    /home/"$USER"/.keys/local.nix-cache.key \
    /home/"$USER"/.keys/nixqemu-luks.key \
    "$REMOTE:/home/nixos/.keys/"
# Preparing..
ssh $SSH_OPTS "$REMOTE" sudo mv -v /home/nixos/nixos-config/ /tmp
ssh $SSH_OPTS "$REMOTE" sudo mv -v /home/nixos/.keys/* /tmp/
echo "All files copied successfully."
