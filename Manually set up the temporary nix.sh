# 1. Manually set up the temporary nix.conf file.
export NIX_CONF_DIR=/tmp/nix-conf
mkdir -p $NIX_CONF_DIR
cat <<EOF > $NIX_CONF_DIR/nix.conf
substituters = http://10.0.20.100:5000?priority=1 https://cache.nixos.org?priority=10
trusted-public-keys = truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
experimental-features = nix-command flakes
EOF

# 2. Restart the nix-daemon.
# This must be run with sudo for systemctl to work.
sudo systemctl restart nix-daemon

# 3. Run the installer. The installer will now use the temporary config.
sudo nixos-install --root "/mnt" --flake "/tmp/nixos-config#nixqemu" -v