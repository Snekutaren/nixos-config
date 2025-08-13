
#!/bin/sh

# Ensure root privileges
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root (use sudo)" >&2
  exit 1
fi

# Set up temporary nix.conf, preserving existing settings
export NIX_CONF_DIR=/tmp/nix-conf
mkdir -p $NIX_CONF_DIR
# Copy existing nix.conf if it exists
cp /etc/nix/nix.conf $NIX_CONF_DIR/nix.conf 2>/dev/null || true

# Overwrite substituters and experimental features
cat <<EOF >> $NIX_CONF_DIR/nix.conf
substituters = http://10.0.20.100:5000?priority=1 https://cache.nixos.org?priority=10
trusted-public-keys = truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
experimental-features = nix-command flakes
EOF

# Restart nix-daemon to apply changes
systemctl restart nix-daemon

# Export NIX_CONF_DIR for the current session
export NIX_CONF_DIR=$NIX_CONF_DIR

# Verify configuration
echo "Verifying Nix configuration..."
nix config show | grep -E 'substituters|trusted-public-keys|experimental-features'

# Test cache connectivity
echo "Testing local cache..."
nix store info --store http://10.0.20.100:5000 || echo "Warning: Local cache unreachable"

echo "Configuration complete. Proceed with:"
echo "nixos-install --flake /path/to/your/flake#your-config"