
alias checkvenv='[ -n "$VIRTUAL_ENV" ] && echo "In venv: $VIRTUAL_ENV" || echo "Not in venv"'
venv_prompt() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename "$VIRTUAL_ENV")) "
  fi
}
for cmd in nv vi vim nano; do alias $cmd='nvim'; done
alias ls='eza -a --icons --git --color=always'
alias ll='eza -lah --icons --git --color=always'
alias lr='eza -lahR --icons --git --color=always'
alias tree='eza --tree --icons --git --color=always'
alias treel='eza --tree --icons --git --color=always | less'
alias comfyui='nix develop ~/comfyui/nix'
alias sshno='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias scpno='scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias bng='cd $BEAMNG'
alias rm='trash-put --'
export BEAMNG="/home/owdious/.local/share/Steam/steamapps/compatdata/284160/pfx/drive_c/users/steamuser/AppData/Local/BeamNG.drive/0.36/mods"

#export PS1='$(venv_prompt)\u@\h:\w\$ '

export PATH="$HOME/.local/bin:$PATH"

function watchtree() {
  watch -c "eza --tree --icons --git --color=always $*"
}
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
function check-flake() {
    sudo nix flake check ~/nixos-config -v
}
function update-flake() {
    sudo nix flake update --flake ~/nixos-config -v
}
function build-attic-push() {
    #local SYSTEM_PATH=$(nix build --no-link --print-out-paths ~/nixos-config#nixosConfigurations.nixrog.config.system.build.toplevel)
    #attic push -j 8 default $SYSTEM_PATH
}
function build-nix-dry() {
    #local SYSTEM_PATH=$(nix build --no-link --print-out-paths ~/nixos-config#nixosConfigurations.nixrog.config.system.build.toplevel)
    #attic push -j 8 default $SYSTEM_PATH
    sudo nixos-rebuild dry-activate --flake ~/nixos-config#nixrog -v
}
function build-nix-test() {
    #local SYSTEM_PATH=$(nix build --no-link --print-out-paths ~/nixos-config#nixosConfigurations.nixrog.config.system.build.toplevel)
    #attic push -j 8 default $SYSTEM_PATH
    sudo nixos-rebuild test --flake ~/nixos-config#nixrog -v
}
function deploy-nix() {
    check-flake && \
    #build-attic-push && \
    sudo nixos-rebuild dry-activate --flake ~/nixos-config#nixrog -v && \
    sudo nixos-rebuild test --flake ~/nixos-config#nixrog -v && \
    sudo nixos-rebuild switch --flake ~/nixos-config#nixrog -v && \
    copy-to-cache && \
    reload-bash
}
function reload-bash() {
    source ~/.bashrc
    echo "Bash configuration reloaded."
}
function reload-hypr() {
    hyprctl reload
    echo "Hyprland configuration reloaded."
}
function copy-to-cache() {
    nix copy --to ssh://x570-machine-vm /run/current-system
    echo "Current build pushed to local cache."
}