      export PATH="$HOME/.local/bin:$PATH"
      function ssha() {
        pidof ssh-agent || eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/github/github_ed25519
      }

      function git-push-nixos() {
        local config_dir="$HOME/nixos-config"
        git -C "$config_dir" checkout auto
        git -C "$config_dir" add .
        git -C "$config_dir" commit -m "$(date)" || true
        git -C "$config_dir" push
      }

      function git-push-dot() {
        local config_dir="$HOME/dotfiles"
        git -C "$config_dir" checkout auto
        git -C "$config_dir" add .
        git -C "$config_dir" commit -m "$(date)" || true
        git -C "$config_dir" push
      }

      function git-push-comfyui() {
        local config_dir="$HOME/comfyui"
        git -C "$config_dir" checkout auto
        git -C "$config_dir" add .
        git -C "$config_dir" commit -m "$(date)" || true
        git -C "$config_dir" push
      }
      
      function update-flake() {
        sudo nix flake update --flake ~/nixos-config -v
      }

      function build-nix() {
        declare -f build-nix
        sudo nixos-rebuild switch --flake ~/nixos-config -v
      }

      function build-nix-dry() {
        sudo nixos-rebuild dry-activate --flake ~/nixos-config -v
      }

      function push-build-nix() {
        ssha
        git-push-dot
        update-flake
        build-nix
        git-push-nixos
      }

      function reload-conf() {
        echo "Bash configuration reloaded."
        hyprctl reload
        echo "Hyprland configuration reloaded."
      }