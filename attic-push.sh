set -euo pipefail

# Simple and reliable attic pusher
find /nix/store -maxdepth 1 -type d \
  | grep -E '/[a-z0-9]{32}-[^/]+$' \
  | grep -vE '\.drv$|-[0-9a-f]{64}' \
  | while IFS= read -r path; do
    if [[ -e "$path" ]]; then
        echo "Pushing $path" >&2
        attic push default "$path" || continue
    fi
done